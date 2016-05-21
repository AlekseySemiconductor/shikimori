(($) ->
  $.fn.extend
    shiki_wall: (opts) ->
      @each ->
        $root = $(@)
        return unless $root.hasClass('unprocessed')

        $root.removeClass('unprocessed')
        # $root.find('.b-video img').each ->
          # if @src.match '/mqdefault.jpg'
            # @src = @src.replace '/mqdefault.jpg', '/hqdefault.jpg'

        $root.imagesLoaded ->
          new ShikiWall($root).mason()

)(jQuery)

wall_id = 0

class WallCluster
  @VERTICAL = 'vertical'
  @HORIZONTAL = 'horizontal'

class @ShikiWall
  constructor: ($node) ->
    @id = (wall_id+=1)

    @$wall = $node.css(width: '', height: '')

    @max_height = parseInt @$wall.css('max-height')
    @max_width = parseInt @$wall.css('width')

    $images = @$wall
      .children('a, .b-video')
      .attr(rel: "wall-#{@id}")
      .css(width: '', height: '')
    $images.children().removeClass 'check-width'

    @images = $images.toArray().map (v) ->
      if v.classList.contains('b-video')
        new WallVideo $(v)
      else
        new WallImage $(v)

    @direction = WallCluster.HORIZONTAL
    @margin = 4

  each: (func) -> @images.each func
  filter: (func) -> @images.filter func
  map: (func) -> @images.map func
  positioned: -> @filter (v) -> v.positioned

  mason: ->
    @each (image) => image.normalize @max_width, @max_height
    @each (image) => @_put image, true
    @each (image) => image.apply()

    width = (@map (v) -> v.left + v.width).max() || 0
    height = (@map (v) -> v.top + v.height).max() || 0

    @$wall.css
      width: ([width, @max_width]).min()
      height: ([height, @max_height]).min()

  _put: (image, post_process) ->
    left = _([0].concat _(@positioned()).map (v) -> v.left + v.width).max() + @margin
    left = 0 if left == @margin

    top = _([0].concat _(@positioned()).map (v) -> v.top + v.height).max() + @margin
    top = 0 if top == @margin

    #delta_x = _.max [left + image.width - @max_width, 0]
    #delta_y = _.max [top + image.height - @max_height, 0]

    #if delta_x && !delta_y
      #throw 'not implemented yet'
      #image.position 0, top

    #else if !delta_x && delta_y
      #throw 'not implemented yet'
      #image.position left, 0

    #else if delta_x && delta_y
      #if @direction == WallCluster.HORIZONTAL
        #image.position left, 0
      #else
        #image.position 0, top

    #else
      #image.position left, top

    if @direction == WallCluster.HORIZONTAL
      image.position left, 0
    else
      image.position 0, top

    @_flatten()
    @_scale()

  _flatten: ->
    images = @positioned()
    return if images.length == 1

    if @direction == WallCluster.HORIZONTAL
      heights = _(images).map (v) -> v.height
      min = _(heights).min()
      if min != _(heights).max()
        _(images).each (image) ->
          image.scale_height min
          image.positioned = false

        _(images).each (image) =>
          @_put image, false

    else
      throw 'not implemented yet'

  _scale: (image, delta_x, delta_y) ->
    images = @positioned()

    if @direction == WallCluster.HORIZONTAL
      current_width = _(images).reduce (memo, v) =>
          memo + v.width + @margin
        , 0.0

      if current_width > @max_width
        _(images).each (image) =>
          image.scale @max_width / current_width
          image.positioned = false

        _(images).each (image) =>
          @_put image, false

    else
      throw 'not implemented yet'

class WallImage
  constructor: ($node) ->
    @$container = $node

    @$image = @$container.find('img')

    # @width = @$image.width() * 1.0
    # @height = @$image.height() * 1.0
    [@width, @height] = @_image_sizes()

    @ratio = @width / @height

    @positioned = false
    @left = 0
    @top = 0

  position: (left, top) ->
    @left = left
    @top = top
    @positioned = true

  apply: ->
    @$image.css
      width: @width
      height: @height

    @$container.css
      top: @top
      left: @left

    @$container.shiki_image()

  normalize: (width, height) ->
    if @width > width
      @scale_width width

    else if @height > height
      @scale_height height

  scale_width: (width) ->
    @height *= width / @width
    @width = width

  scale_height: (height) ->
    @width *= height / @height
    @height = height

  scale: (percent) ->
    @width *= percent
    @height *= percent

  _image_sizes: ->
    [
      @$image[0].naturalWidth * 1.0
      @$image[0].naturalHeight * 1.0
    ]

class WallVideo extends WallImage
  HEIGHT_RATIO =
    other: 1.0
    vk: 0.75417

  constructor: ($node) ->
    @is_vk = $node.hasClass('vk')
    super

  apply: ->
    @$image.css
      width: @width
      # height: @height / @_height_ratio()

    @$container.css
      top: @top
      left: @left
      width: @width
      height: @height

  _image_sizes: ->
    [
      @$image[0].naturalWidth * 1.0
      @$image[0].naturalHeight * 1.0 * @_height_ratio()
    ]

  _height_ratio: ->
    HEIGHT_RATIO[if @is_vk then 'vk' else 'other']
