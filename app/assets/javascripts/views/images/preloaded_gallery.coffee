using 'Images'
class Images.PreloadedGallery extends View
  @BATCH_SIZE = 5
  TEMPLATE = 'images/image'

  APPEAR_MARKER_HTML =
    '<p class="ajax-loading vk-like b-appear_marker active" ' +
      'data-appear-top-offset="900"></p>'

  DEPLOY_INTERVAL = 100
  APPEND_ACTION = 'appended'
  PREPEND_ACTION = 'prepended'

  initialize: ->
    @rel = @$root.data 'rel'
    @can_load = true

    @$container = @$('.container')

    @can_upload = @$root.data 'can_upload'
    @can_destroy = @$root.data 'can_destroy'
    @destroy_url = @$container.data 'destroy_url'

    @$root.gallery
      shiki_upload: @$root.data('can_upload')
      shiki_upload_custom: true

    @packery = @$root.packery

    @on 'upload:success', @_append_uploaded

    @_build_loader().then =>
      if @loader
        @loader.on @loader.FETCH_EVENT, @_images_load

        @_appear_marker()
        @_fetch()

  # callbacks
  # loader returned images
  _images_load: (images) =>
    images_html = images.map (image) => @_image_to_html(image)

    $batch = $(images_html.join(''))
    $batch.imagesLoaded @_deploy_batch

  _after_batch_deploy: =>
    if @loader.is_finished()
      @$appear_marker.remove()
    else
      @_start_postload()

  _append_uploaded: (e, image) =>
    $image = $(@_image_to_html(image))
    $image.imagesLoaded => @_deploy_image $image, 0, PREPEND_ACTION

  # private methods
  _build_loader: ->
    require.ensure [], (require) =>
      StaticLoader = require 'services/images/static_loader'

      images = @$container.data 'images'
      if images
        @loader = new StaticLoader(Images.PreloadedGallery.BATCH_SIZE, images)

  _appear_marker: ->
    @$appear_marker = $(APPEAR_MARKER_HTML).insertAfter @$container
    @$appear_marker.on 'appear', @_fetch

  _fetch: (e) =>
    if @can_load
      @loader.fetch()
      @_stop_postload()

  _start_postload: ->
    @can_load = true
    @_fetch() if @$appear_marker.is(':appeared')

  _stop_postload: ->
    @can_load = false

  _image_to_html: (image) ->
    JST[TEMPLATE]
      image: image,
      rel: @rel
      destroy_url: (@destroy_url.replace('ID', image.id) if @can_destroy)

  _deploy_batch: (images) =>
    images.elements.forEach (image_node, index) =>
      @_deploy_image image_node, index, APPEND_ACTION
    # recheck postloader appearence after all images are deployed
    delay((images.elements.length + 1) * DEPLOY_INTERVAL).then =>
      @_after_batch_deploy()

  _deploy_image: (image_node, index, action) =>
    $image = $(image_node)
      .shiki_image()
      .css(bottom: 9999)

    delay(index * DEPLOY_INTERVAL).then => @$container.packery(action, $image)
    @$container.append($image)
