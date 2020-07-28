import bind from 'bind-decorator';
import axios from 'helpers/axios';

import View from 'views/application/view';

export default class Clickloaded extends View {
  isLoading = false;

  initialize() {
    this.$root.on('click', this.fetch);
  }

  @bind
  async fetch() {
    if (this.isLoading) { return; }
    this.isLoading = true;
    const html = this.$root.html();

    this.$root.trigger('clickloaded:before');

    this.$root.html(
      `<div
        class='ajax-loading vk-like'
        title='${I18n.t('frontend.blocks.click_loader.loading')}'
      />`
    );

    const { data } = await axios.get(this.$root.data('clickloaded-url'));

    this.$root.html(html);
    this.$root.trigger('clickloaded:success', [data]);
    this.isLoading = false;
  }
}
