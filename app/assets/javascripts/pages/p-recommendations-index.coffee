@on 'page:load', 'recommendations_index', 'recommendations_favourites', ->
  # если страница ещё не готова, перегрузимся через 5 секунд
  if $('p.pending').exists()
    url = location.href
    (->
      Turbolinks.visit(location.href, true) if url == location.href
    ).delay 5000

  $('body').on 'mouseover', '.b-catalog_entry', ->
    return unless USER_SIGNED_IN
    $node = $(@)
    return if $node.hasClass 'entry-ignored'

    if $node.data 'ignore_augmented'
      $node.data('ignore_button').show()
    else
      title = t('frontend.pages.p_recommendations_index.dont_recommend_franchise')
      $button = $("<span class='controls'><span class='delete mark-ignored' title=\"#{title}\"></span></span>")
        .appendTo($node.find('.image-cutter'))
      $node.data
        ignore_augmented: true
        ignore_button: $button

  $('body').on 'mouseout', '.b-catalog_entry', ->
    $button = $(@).data('ignore_button')
    $button.hide() if $button

  $('body').on 'click', '.entry-ignored', (e) ->
    false unless in_new_tab(e)

  $('body').on 'click', '.b-catalog_entry .mark-ignored', ->
    $node = $(@).closest '.b-catalog_entry'
    $link = $node.find('a').first()

    if $link.attr('href').match /(anime|manga)s\//
      target_type = RegExp.$1
      target_id = $node.prop('id')

      $.post '/recommendation_ignores', target_type: target_type, target_id: target_id, (data) ->
        selector = _(data).map((v) -> ".entry-#{v}").join(',')
        $(selector).addClass 'entry-ignored'

      $node.addClass 'entry-ignored'
      $(@).hide()
      AjaxCacher.reset()
    false
