Kinetic = require("../../../jslibs/kinetic").Kinetic
KStimulus = require("../../stimresp").KineticStimulus


# A rectangle graphical element
class Rectangle extends KStimulus

  defaults:
    x: 0, y: 0, width: 100, height: 100, opacity: 1, fill: "black"

  # Construct a new Rectangle.
  #
  # @param [Object] spec component parameters
  # @option options [Int] x the x coordinate
  # @option options [Int] y the y coordinate
  # @option options [Int] width the width of the rectangle
  # @option options [Int] height the height of the rectangle
  # @option options [Number] opacity the opacity of the Rectangle (0 is transparent, 1 opaque)
  # @option options [String] fill the color of the rectangle
  # @option options [String] stroke the color of the outline
  constructor: (spec = {}) ->
    super(spec)



  render: (context) ->
    console.log("rendering rectangle")
    coords = @computeCoordinates(context, @spec.position, @spec.width, @spec.height)
    rect = new Kinetic.Rect({ x: coords[0], y: coords[1], width: @spec.width, height: @spec.height, fill: @spec.fill, stroke: @spec.stroke, strokeWidth: @spec.strokeWidth, opacity: @spec.opacity})
    #{x: coords[0], y: coords[1], width: @spec.width, height: @spec.height}
    @presentable(rect)

exports.Rectangle = Rectangle