pageLoad('animes_show', 'mangas_show', 'ranobe_show', async () => {
  $('.b-notice').tipsy({ gravity: 's' });
  $('.c-screenshot').magnificRelGallery();

  $('.text').checkHeight({ maxHeight: 200 });

  const $newCritique = $('.new_critique');
  if (window.SHIKI_USER.isSignedIn) {
    const newCritiqueUrl = $newCritique
      .attr('href')
      .replace(/%5Buser_id%5D=(\d+|ID)/, `%5Buser_id%5D=${window.SHIKI_USER.id}`);
    $newCritique.attr({ href: newCritiqueUrl });
  } else {
    $newCritique.hide();
  }

  // autoload of resource info for guests
  $('.l-content').on('postloaded:success', '.resources-loader', () => (
    $('.c-screenshot').magnificRelGallery()
  ));

  $('.other-names').on('clickloaded:success', ({ currentTarget }, data) => {
    $(currentTarget).closest('.line').replaceWith(data);
  });

  $('.b-subposter-actions .new_comment').on('click', () => {
    $('.shiki_editor-selector').view().focus();
  });

  const [{ FavoriteStar }, { LangTrigger }] = await Promise.all([
    import(/* webpackChunkName: "db_entries_show" */ '@/views/db_entries/favorite_star'),
    import(/* webpackChunkName: "db_entries_show" */ '@/views/db_entries/lang_trigger')
  ]);

  new LangTrigger('.b-lang_trigger');
  new FavoriteStar($('.b-subposter-actions .fav-add'), gon.is_favoured);

  const NAVIGATION_SELECTOR = '.summaries-navigation .navigation-block';
  $(NAVIGATION_SELECTOR).on('click', ({ currentTarget }) => {
    if (currentTarget.classList.contains('is-active')) {
      return;
    }
    $(`${NAVIGATION_SELECTOR}.is-active`).removeClass('is-active');
    currentTarget.classList.add('is-active');

    $(`${NAVIGATION_SELECTOR}[data-ellispsis-allowed]`)
      .removeClass('is-ellipsis');

    $(`${NAVIGATION_SELECTOR}[data-ellispsis-allowed]:not(.is-active)`)
      .last()
      .addClass('is-ellipsis');
  });
});
