Stimulus = require("../../stimresp").Stimulus
Kinetic = require("../../../jslibs/kinetic").Kinetic

class Arrow extends Stimulus

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

    })


    computedLength = shaftLength + @spec.arrowSize
    computedHeight = @spec.thickness
    @group = new Kinetic.Group({x: 0, y: 0, rotationDeg: @angle, offset: [computedLength/2, @spec.thickness/2]})
    @group.add(@arrowShaft)
    @group.add(@arrowHead)

    coords = @computeCoordinates(context, @spec.position, computedLength, computedHeight)


    # need to recenter
    @group.setPosition({x: coords[0] + computedLength/2, y: coords[1] + @spec.thickness/2})


  render: (context, layer) ->
    layer.add(@group)



exports.Arrow = Arrow

