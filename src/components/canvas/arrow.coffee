Stimulus = require("../../stimresp").Stimulus
Kinetic = require("../../../jslibs/kinetic").Kinetic

class Arrow extends Stimulus

  defaults:
    x: 100, y: 100, length: 100, direction: "right", thickness: 40, fill: "red", arrowSize: 25, angle: null


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

    console.log("arrowhead width", @arrowHead.getWidth())
    console.log("arrowhead height", @arrowHead.getHeight())
    console.log("shaft width", @arrowShaft.getWidth())
    console.log("shaft height", @arrowShaft.getHeight())

    computedLength = shaftLength + @spec.arrowSize
    computedHeight = @spec.thickness
    @group = new Kinetic.Group({x: 0, y: 0, rotationDeg: @angle, offset: [computedLength/2, @spec.thickness/2]})
    #@group = new Kinetic.Group({x: 0, y: 0, rotationDeg: @angle})
    #@group = new Kinetic.Group({x: 0, y: 0})
    @group.add(@arrowShaft)
    @group.add(@arrowHead)

    console.log("computed height", computedHeight)

    coords = @computeCoordinates(context, @spec.position, computedLength, computedHeight)

    console.log("coords", coords)

    # need to recenter
    @group.setPosition({x: coords[0] + computedLength/2, y: coords[1] + @spec.thickness/2})


  render: (context, layer) ->
    layer.add(@group)



exports.Arrow = Arrow

