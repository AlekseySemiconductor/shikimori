# получение комментария
$comment = (node) ->
  $(node).closest('.b-abuse_request').find('.b-comment')

$moderation = (node) ->
  $(node).closest('.b-abuse_request').find('.b-request_resolution .moderation')

# раскрытие информации о загрузке видео
@on 'page:load', 'anime_video_reports_index', 'profiles_videos', ->
  $('.l-page').on 'click', '.b-log_entry.video .collapsed', ->
    $player = $(@).parent().find('.player')

    if $player.data 'html'
      $player
        .html($player.data 'html')
        .data(html: '')

# страница модерации правок
@on 'page:load', 'versions_index', ->
  picker = new DatePicker('.date-filter')
  picker.on 'date:picked', ->
    new_url = new URI(location.href).setQuery('created_on', @value).href()
    Turbolinks.visit new_url

# страницы модерации
@on 'page:load', 'bans_index', 'abuse_requests_index', 'versions_index', 'review_index', ->
  # сокращение высоты инструкции
  $('.b-brief').check_height max_height: 150

  $('.expand-all').on 'click', ->
    $(@).parent().next().next().find('.collapsed.spoiler:visible').click()
    $(@).remove()

# информация о пропущенных видео
@on 'page:load', 'moderations_missing_videos', ->
  $('.missing-video .show-details').on 'click', ->
    $(@).parent()
      .find('.details')
      .toggleClass('hidden')
    false

  $('.missing-video .show-details').one 'click', ->
    $.get $(@).data('episodes_url'), (html) =>
      $(@).parent()
        .find('.details')
        .html(html)
    false
