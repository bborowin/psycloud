Stimulus = require("../../stimresp").Stimulus
Kinetic = require("../../../jslibs/kinetic").Kinetic

class Rectangle extends Stimulus

  defaults:
    x: 0, y: 0, width: 100, height: 100, fill: 'red', opacity: 1

  constructor: (spec = {}) ->
    super(spec)



  render: (context, layer) ->
    coords = @computeCoordinates(context, @spec.position, @spec.width, @spec.height)
    rect = new Kinetic.Rect({ x: coords[0], y: coords[1], width: @spec.width, height: @spec.height, fill: @spec.fill, stroke: @spec.stroke, strokeWidth: @spec.strokeWidth, opacity: @spec.opacity})
    layer.add(rect)

exports.Rectangle = Rectangle