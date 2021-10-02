import { memoize } from 'shiki-decorators';
import { isPhone } from 'shiki-utils';

import Topic from './topic';

export default class Review extends Topic {
  _type() { return 'review'; }
  _typeLabel() { return I18n.t('frontend.dynamic_elements.review.type_label'); } // eslint-disable-line camelcase

  initialize() {
    const mobileOffset = isPhone() ? 63 : 0;

    this.CHECK_HEIGHT_MAX_PREVIEW_HEIGHT = 220 + mobileOffset;
    this.CHECK_HEIGHT_COLLAPSED_HEIGHT = 170 + mobileOffset;
    this.CHECK_HEIGHT_PLACEHOLDER_HEIGHT = 115 + mobileOffset;

    super.initialize();
    this._scheduleCheckHeight();
  }

  @memoize
  get $checkHeightNode() {
    return this.$inner;
  }
}
