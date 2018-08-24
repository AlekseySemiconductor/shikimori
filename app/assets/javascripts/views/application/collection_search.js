import URI from 'urijs';
import { debounce } from 'throttle-debounce';

import View from 'views/application/view';
import axios from 'helpers/axios';

const PENDING_REQUEST = 'pending_request';

export default class CollectionSearch extends View {
  cache = {}

  initialize() {
    this.$collection = this.$root.find('.searchable-collection');
    if (!this.$collection.length) {
      console.warn('not found .searchable-collection');
    }

    this.$input = this.$('.field input');
    this.$clear = this.$('.field .clear');

    this.debounced_search = debounce(250, () => this._search());
    this.current_phrase = this._searchPhrase();

    this.$clear.toggle(!Object.isEmpty(this.current_phrase));
    // @$input.focus() if @$input.is(':appeared')

    this.$input.on('change blur keyup paste', e => this._filterChanged(e));
    this.$clear.on('click', () => this._clearPhrase());
  }

  // handlers
  _filterChanged(e) {
    const phrase = this._searchPhrase();

    if (e.keyCode === 27) {
      if (Object.isEmpty(phrase)) {
        this.$input.blur();
      } else {
        this._clearPhrase();
      }
      return;
    }

    if (phrase === this.current_phrase) { return; }

    if (phrase.length === 1) {
      this._hideAjax();
    } else {
      this.current_phrase = phrase;
      this.debounced_search();
      this._showAjax();

      this.$clear.toggle(!Object.isEmpty(phrase));
    }
  }

  _clearPhrase() {
    return this.$input
      .val('')
      .trigger('change')
      .focus();
  }

  // private functions
  async _search() {
    const phrase = this._searchPhrase();
    if (this.cache[phrase] === PENDING_REQUEST) { return; }

    if (phrase.length === 1) {
      this._hideAjax();
    } else if (this.cache[phrase]) {
      this._showResults(this.cache[phrase], this._searchUrl(phrase));
    } else {
      const response = await axios.get(this._searchUrl(phrase));
      this.cache[phrase] = response.data;

      if (phrase === this._searchPhrase()) {
        this._showResults(this.cache[phrase], this._searchUrl(phrase));
      }
    }
  }

  _showResults(response, searchUrl) {
    this._processResponse(response);
    this._hideAjax();

    window.history.replaceState(
      { turbolinks: true, url: searchUrl },
      '',
      searchUrl
    );
  }

  _processResponse(response) {
    let html;

    if (response.content) {
      html = response.content + (response.postloader || '');
    } else {
      html = JST['search/nothing_found']();
    }

    this.$collection.html(html).process();
  }

  _searchPhrase() {
    return this.$input.val().trim();
  }

  _searchUrl(phrase) {
    const uri = URI(this.$root.data('search_url'));

    if (phrase) {
      return uri.query({ search: phrase });
    }
    return uri.removeQuery('search');
  }

  _showAjax() {
    this.$collection.addClass('b-ajax');
  }

  _hideAjax() {
    this.$collection.removeClass('b-ajax');
  }
}
