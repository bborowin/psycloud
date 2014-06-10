#Kinetic = require("../../../jslibs/kinetic").Kinetic
KStimulus = require("../../stimresp").KineticStimulus

class Picture extends KStimulus
  defaults:
    url: "http://www.html5canvastutorials.com/demos/assets/yoda.jpg", x: 0, y: 0, stroke: null, strokeWidth: 0, position: null

  # Construct a new Picture.
  #
  # @param [Object] spec component parameters
  # @option options [Int] x the x coordinate
  # @option options [Int] y the y coordinate
  # @option options [Int] stroke the color of the border (optional)
  # @option options [Int] width the width of the border stroke
  # @option options [String] position the position constraint
  # @option options [String] url the url of the image
  constructor: (spec = {}) ->
    super(spec)

    @image = null


  initialize: ->
    @imageObj = new Image()
    @imageObj.onload = =>
      console.log("image loaded", @spec.url)
      @image = new Kinetic.Image({
        x: @spec.x,
        y: @spec.y,
        image: @imageObj,
        width: @spec.width or @imageObj.width,
        height: @spec.height or @imageObj.height
        stroke: @spec.stroke
        strokeWidth: @spec.strokeWidth
        id: @spec.id

      })

    @imageObj.src = @spec.url




  render: (context) ->

    console.log("rendering image", @image)
    coords = @computeCoordinates(context, @spec.position, @image.getWidth(), @image.getHeight())
    @image.setPosition({x: coords[0], y: coords[1]})
    @presentable(this, @image)


exports.Picture = Picture

