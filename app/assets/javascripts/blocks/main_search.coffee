# спецэкранирование некоторых символов поиска
search_escape = (phrase) ->
  (phrase || '')
    .replace(/\+/g, '(l)')
    .replace(/ +/g, '+')
    .replace(/\\/g, '(b)')
    .replace(/\//g, '(s)')
    .replace(/\./g, '(d)')
    .replace(/%/g, '(p)')

# автодополнение
$(document).on 'page:load', ->
  $main_search = $('.b-main_search')
  $search = $('.b-main_search input')
  $popup = $('.b-main_search .popup')

  return unless $('.b-main_search').exists()

  # из урла достаём текущий тип поиска
  type = location.pathname.replace(/^\//, "").replace(/\/.*/, "")
  type = $search.data('type') unless searcheables[type]

  # во всплывающей выборке типов устанавливаем текущий тип
  $(".type[data-type=#{type}], .type[data-type=#{type}]", $popup).addClass 'active'

  # автокомплит
  $search
    .data
      type: type
      autocomplete: searcheables[type].autocomplete
    .attr(placeholder: I18n.t("frontend.blocks.main_search.#{type}"))
    .completable($('.b-main_search .suggest-placeholder'))

    .on 'autocomplete:success', (e, entry) ->
      type = $search.data 'type'
      markers = $main_search.data 'markers'

      if type == 'users'
        document.location.href = "/#{search_escape entry.name}"
      else
        document.location.href =
          searcheables[type].id.replace('[id]', "aaaaaaa#{entry.id}")

    .on 'autocomplete:text', (e, text) ->
      type = $search.data('type')
      document.location.href = searcheables[type].phrase.replace('[phrase]', search_escape(text))

  $search.on 'parse', ->
    $popup.addClass 'disabled'
    (-> $('.ac_results:visible').addClass 'menu-suggest').delay()

  # переключение типа поиска
  $('.b-main_search .type').on 'click', ->
    return if $(@).hasClass('active')
    $(@).addClass('active').siblings().removeClass "active"
    type = $(@).data('type')

    $search
      .data(type: type)
      .attr(placeholder: I18n.t("frontend.blocks.main_search.#{type}"))
      .data(autocomplete: searcheables[type].autocomplete)
      .trigger('flushCache')
      .focus()

    # скритие типов
    $popup.addClass 'disabled'

  # включение и отключение выбора типов
  $popup.on 'hover', ->
    $search.focus()

  $search.on 'keypress', ->
    $popup.addClass "disabled"

  $search.on 'click', ->
    if $('.ac_results:visible').length
      $popup.addClass 'disabled'
    else
      $popup.toggleClass 'disabled'

  $search.on 'hover', ->
    $popup.addClass 'disabled' if $('.ac_results:visible').length

  $main_search.on 'click', (e) ->
    $search.trigger('click').trigger('focus') if $(e.target).hasClass('b-main_search')

  $main_search.hover_delayed ->
    $main_search.addClass 'hovered'
  , ->
    $main_search.removeClass 'hovered'
  , 250

# конфигурация автодополнений
searcheables =
  animes:
    autocomplete: "/animes/autocomplete/"
    phrase: "/animes/search/[phrase]"
    id: "/animes/[id]"
    regexp: /.*\/search\/(.*?)\/.*/

  mangas:
    autocomplete: "/mangas/autocomplete/"
    phrase: "/mangas/search/[phrase]"
    id: "/mangas/[id]"
    regexp: /.*\/search\/(.*?)\/.*/

  characters:
    autocomplete: "/characters/autocomplete/"
    phrase: "/characters/search/[phrase]"
    id: "/characters/[id]"
    regexp: /^\/characters\/(.*?)/

  seyu:
    autocomplete: "/people/autocomplete?kind=seyu"
    phrase: "/seyu/search/[phrase]"
    id: "/seyu/[id]"
    regexp: /^\/seyu\/(.*?)/

  producers:
    autocomplete: "/people/autocomplete?kind=producer"
    phrase: "/producers/search/[phrase]"
    id: "/person/[id]"
    regexp: /^\/producer\/(.*?)/

  mangakas:
    autocomplete: "/people/autocomplete?kind=mangaka"
    phrase: "/mangakas/search/[phrase]"
    id: "/person/[id]"
    regexp: /^\/mangaka\/(.*?)/

  people:
    autocomplete: "/people/autocomplete/"
    phrase: "/people/search/[phrase]"
    id: "/person/[id]"
    regexp: /^\/people\/(.*?)/

  users:
    autocomplete: "/users/autocomplete/"
    phrase: "/users/search/[phrase]"
    id: "/[id]"
    regexp: /^\/users\/(.*?)/
