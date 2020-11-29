import Cosplay from 'views/animes/cosplay';

pageLoad('characters_show', async () => {
  $('.text').checkHeight({ maxHeight: 200 });

  $('.b-subposter-actions .new_comment').on('click', () => {
    $('.shiki_editor-selector').view().focus();
  });

  const [{ FavoriteStar }, { LangTrigger }] = await Promise.all([
    import(/* webpackChunkName: "db_entries_show" */ 'views/db_entries/favorite_star'),
    import(/* webpackChunkName: "db_entries_show" */ 'views/db_entries/lang_trigger')
  ]);

  new LangTrigger('.b-lang_trigger');
  new FavoriteStar($('.b-subposter-actions .fav-add'), gon.is_favoured);
});

pageLoad('characters_art', async () => {
  const { ImageboardsGallery } =
    await import(/* webpackChunkName: "galleries" */ 'views/images/imageboards_gallery');

  new ImageboardsGallery('.b-gallery');
});
pageLoad('characters_cosplay', () => {
  new Cosplay('.l-content');
});
