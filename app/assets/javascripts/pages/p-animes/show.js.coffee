@on 'page:load', 'animes_show', 'mangas_show', ->
  $('.b-notice').tipsy gravity: 's'
  $('.c-screenshot').magnific_rel_gallery()

  # сокращение высоты описания
  $('.text').check_height(200)

  new FavouriteStar $('.c-actions .fav-add'), is_favoured
  new Animes.WathOnlineButton $('.watch-online-placeholer'), watch_online

  $new_review = $('.new_review')
  if $new_review.length
    new_review_url = $new_review
      .attr('href').replace(/%5Buser_id%5D=\d+/, "%5Buser_id%5D=#{USER_ID}")
    $new_review.attr href: new_review_url

  # автоподгрузка блока с расширенной инфой об аниме для гостей
  $('.l-content').on 'postloaded:success', '.resources-loader', ->
    $('.c-screenshot').magnific_rel_gallery()
    $('.b-show_more').show_more()

  # клик по загрузке других названий
  $('.other-names.click-loader').on 'ajax:success', (e, data) ->
    $(@).closest('.line').replaceWith data

  (->
    # клик по смотреть онлайн
    $('.watch-online').on 'click', ->
      episode = parseInt($('.b-db_entry .b-user_rate .current-episodes').html())
      total_episodes = parseInt($('.b-user_rate .total-episodes').html()) || 9999
      watch_episode = if !episode || episode == total_episodes then 1 else episode + 1

      $(@).attr href: $(@).attr('href').replace(/\d+$/, watch_episode)
  ).delay()

  # раскрытие свёрнутого блока связанного
  $('.l-content').on 'click', '.related-shower', ->
    $(@).next().children().unwrap()
    $(@).siblings().show()
    $(@).remove()

  # комментировать
  $('.c-actions .new_comment').on 'click', ->
    $editor = $('.b-form.new_comment textarea')
    $.scrollTo $editor, ->
      $editor.focus()

  # переключение типа комментариев
  $('.entry-comments .link')
    .on 'ajax:before', (e) ->
      $(@)
        .addClass('selected')
        .data(disabled: true)
      $(@)
        .siblings('span')
        .removeClass('selected')
        .data(disabled: false)
      $(@)
        .parents('.entry-comments')
        .find('.comments-container')
        .animate(opacity: 0.3)
    .on 'ajax:success', (e, data) ->
      $container = $(@)
        .parents('.entry-comments')
        .find('.comments-container')
        .animate(opacity: 1)
      $container
        .children(':not(.shiki-editor)')
        .remove()
      $container.append data.content
