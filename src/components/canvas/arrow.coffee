KStimulus = require("../../stimresp").KineticStimulus
Kinetic = require("../../../jslibs/kinetic").Kinetic

class Arrow extends KStimulus

  defaults:
    x: 100, y: 100, length: 100, direction: "right", thickness: 40, fill: "black", arrowSize: 25, angle: null


  # Construct a new Arrow.
  #
  # @param [Object] spec component parameters
  # @option options [Int] x the x coordinate
  # @option options [Int] y the y coordinate
  # @option options [Int] length the length of the arrow
  # @option options [String] the direction direction the arrow is pointing (one of: 'left', 'right', 'up', 'down')
  # @option options [Int] thickness the thickness of the arrow shaft
  # @option options [String] fill the color of the arrow
  # @option options [Int] arrowSize the length of the equilateral triangle for the arrow head
  # @option options [Number] angle the arrow rotation (where 0 is pointing right, 180 left)
  constructor: (spec = {}) ->
    super(spec)


  initialize: ->

    if @spec.angle?
      @angle = @spec.angle
    else
      @angle = switch @spec.direction
        when "right" then 0
        when "left"  then 180
        when "up" then 90
        when "down" then 270
        else 0

    shaftLength = @spec.length - @spec.arrowSize

    @arrowShaft = new Kinetic.Rect({x: 0, y: 0, width: shaftLength, height: @spec.thickness, fill: @spec.fill, stroke: @spec.stroke, strokeWidth: @spec.strokeWidth, opacity: @spec.opacity})

    _this = @

    @arrowHead = new Kinetic.Shape({
      drawFunc: (cx) ->
        cx.beginPath()

        cx.moveTo(shaftLength, -_this.spec.arrowSize / 2.0)

        cx.lineTo(shaftLength + _this.spec.arrowSize, _this.spec.thickness / 2.0)

        cx.lineTo(shaftLength, _this.spec.thickness + _this.spec.arrowSize / 2.0)

        cx.closePath()

        cx.fillStrokeShape(this)

      fill: _this.spec.fill
      stroke: @spec.stroke
      strokeWidth: @spec.strokeWidth
      opacity: @spec.opacity
      width: _this.spec.arrowSize
      height: _this.spec.arrowSize + _this.spec.thickness
     # x: shaftLength
     # y: 0

    })


    len = shaftLength + @spec.arrowSize
    height = @spec.thickness

    @node = new Kinetic.Group({x: 0, y: 0, rotationDeg: @angle, offset: [len/2, height/2]})
    @node.add(@arrowShaft)
    @node.add(@arrowHead)


  render: (context) ->
    coords = @computeCoordinates(context, @spec.position, @arrowShaft.getWidth(), @arrowShaft.getHeight())
    # need to recenter
    @node.setPosition({x: coords[0] + (@arrowShaft.getWidth()+@spec.arrowSize)/2, y: coords[1] + @spec.thickness/2})
    @presentable(@node)



exports.Arrow = Arrow

