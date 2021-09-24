pageLoad('.animes', '.mangas', '.ranobe', async () => {
  if ($('.b-animes-menu').exists()) {
    const { AnimesMenu } =
      await import(/* webpackChunkName: "db_entries_menu" */ '@/views/db_entries/menu');
    new AnimesMenu('.b-animes-menu');
  }

  const { ReviewsNavigation } =
    await import(/* webpackChunkName: "db_entries_menu" */ '@/views/db_entries/reviews_navigation');

  new ReviewsNavigation('.b-reviews_navigation');
});
