import delay from 'delay';
import { flash, isPhone } from 'shiki-utils';
import { bind } from 'shiki-decorators';

import ShikiEditable from '@/views/application/shiki_editable';
import { loadImagesFinally, imagePromiseFinally } from '@/utils/load_image';

const I18N_KEY = 'frontend.dynamic_elements.comment';

export default class Comment extends ShikiEditable {
  _type() { return 'comment'; }
  _typeLabel() { return I18n.t(`${I18N_KEY}.type_label`); }

  // similar to hash from JsExports::CommentsExport#serialize
  _defaultModel() {
    return {
      can_destroy: false,
      can_edit: false,
      id: parseInt(this.node.id),
      is_viewed: true,
      user_id: this.$node.data('user_id')
    };
  }

  initialize() {
    const mobileOffset = isPhone() ? -25 : 0;
    this.CHECK_HEIGHT_PLACEHOLDER_HEIGHT = 140 + mobileOffset;

    // data attribute is set in Comments.Tracker
    this.model = this.$node.data('model') || this._defaultModel();

    if (window.SHIKI_USER.isUserIgnored(this.model.user_id)) {
      // node can be not inserted into DOM yet
      if (this.$node.parent().length) {
        this.$node.remove();
      } else {
        delay().then(() => this.$node.remove());
      }
      return;
    }

    this.$body = this.$('.body');
    if (this.model && !this.model.is_viewed) {
      this._activateAppearMarker();
    }

    this._scheduleCheckHeight();

    this.$('.item-offtopic, .item-summary').on('click', this._markOfftopicOrSummary);
    this.$('.item-spoiler, .item-abuse').on('ajax:before', this._markSpoilerOrAbuse);

    this.on('faye:comment:set_replies', this._fayeSetReplies);

    this.$('.hash').one('mouseover', this._replaceHashWithLink);
  }

  mark(kind, value) {
    this.$(`.item-${kind}`).toggleClass('selected', value);
    this.$(`.b-${kind}_marker`).toggle(value);
  }

  _isOfftopic() {
    return this.$('.b-offtopic_marker').css('display') !== 'none';
  }

  @bind
  _markOfftopicOrSummary({ currentTarget }) {
    const confirmType = currentTarget.classList.contains('selected') ?
      'remove' :
      'add';

    $(currentTarget).attr(
      'data-confirm',
      $(currentTarget).data(`confirm-${confirmType}`)
    );
  }

  @bind
  _markSpoilerOrAbuse({ currentTarget }) {
    const reason = prompt($(currentTarget).data('reason-prompt'));

    // return value grabbed by triggerAndReturn in rauils_ujs
    if (reason == null) { return false; }

    $(currentTarget).data({ form: { reason } });
    return true;
  }

  @bind
  _fayeSetReplies(_e, data) {
    this.$('.b-replies').remove();
    $(data.replies_html).appendTo(this.$body).process();
  }

  @bind
  _replaceHashWithLink({ currentTarget }) {
    const $node = $(currentTarget);

    $node
      .attr('href', $node.data('url'))
      .changeTag('a');
  }
}
