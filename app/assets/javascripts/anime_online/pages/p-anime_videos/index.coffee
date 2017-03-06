@on 'page:load', 'anime_videos_index', ->
  $('.b-show_more').show_more()

  resize_video_player()

  debounced_resize = $.debounce(250, resize_video_player)
  debounced_resize()
  $(window).on('resize', debounced_resize)
  $(window).one('page:before-unload', -> $(window).off 'resize', debounced_resize)

  # html 5 video player
  $video = $('.b-video_player video')
  new ShikiHtml5Video $video if $video.length

  # highlight current episode
  $anime_video_episodes = $('.c-anime_video_episodes')
  current_episode = $anime_video_episodes.data 'episode'
  $(
    ".b-video_variant[data-episode='#{current_episode}'] a", $anime_video_episodes
  ).addClass 'active'

  # переключение вариантов видео
  $('.video-variant-switcher').on 'click', switch_video_variant

  # показ дополнительных кнопок для видео
  $('.cc-player_controls .show-options').on 'click', toggle_options

  # добавление в список
  $('.cc-player_controls').on 'ajax:success', '.create-user_rate', ->
    $link = $(@)

    $.notice 'Аниме добавлено в список'
    $link
      .removeClass('create-user_rate')
      .addClass('increment-user_rate')
      .attr
        href: $link.data('increment_url')

    $link
      .find('.label')
      .text $link.data('increment_text')

  # отметка о прочтении
  $('.cc-player_controls').on 'ajax:success', '.increment-user_rate', ->
    unless $('.increment-user_rate').hasClass('watched')
      $.notice 'Эпизод отмечен просмотренным'
    (-> Turbolinks.visit $('.c-control.next').attr('href')).delay 500

  # кнопка жалобы
  $('.cc-player_controls .report').on 'click', ->
    if $(@).hasClass 'selected'
      hide_report()
    else
      show_report()

  # отмена жалобы
  $('.cc-anime_video_report-new .cancel').on 'click', hide_report

  # сабмит жалобы
  $('.cc-anime_video_report-new form').on 'ajax:success', ->
    $.notice 'Жалоба успешно отправлена и вскоре будет рассмотрена модератором. Домо аригато'
    hide_report()

  # инкремент числа просмотров
  $player = $('.b-video_player')
  video_url = location.href
  if $player.data('watch-delay')
    (->
      if video_url == location.href
        $.post $player.data('watch-url')
    ).delay $player.data('watch-delay')

show_report = ->
  $('.cc-player_controls .report').addClass 'selected'
  $('.cc-options').hide()
  $('.cc-anime_video_report-new').show()

hide_report = ->
  $('.cc-player_controls .report').removeClass 'selected'
  $('.cc-options').show()
  $('.cc-anime_video_report-new').hide()
  toggle_options

toggle_options = ->
  $('.cc-player_controls .show-options').toggleClass 'selected'
  $('.cc-navigation').toggle()
  $('.cc-optional_controls').toggle()

resize_video_player = ->
  $player = $('iframe,object,embed,.player-placeholder', '.player-area')
  $player.height($player.width() * 9 / 16)

switch_video_variant = (e) ->
  kind = $(e.target).data('kind')

  $('.video-variant-switcher').removeClass 'active'
  $(e.target).addClass 'active'

  $('.video-variant-group').removeClass 'active'
  $(".video-variant-group[data-kind='#{kind}']").addClass 'active'
