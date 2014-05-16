
#Kinetic = require("../../../jslibs/kinetic").Kinetic
KStimulus = require("../../stimresp").KineticStimulus


# Draws a border around canvas perimeter
class CanvasBorder extends KStimulus

  defaults:
    strokeWidth: 5, stroke: "black"

  # Construct a new CanvasBorder.
  #
  # @param [Object] spec component parameters
  # @option options [Int] strokeWidth the width of the border
  # @option options [Int] stroke the color of the border
  constructor: (spec = {}) ->
    super(spec)

  render: (context) ->
    border = new Kinetic.Rect({ x: 0, y: 0, width: context.width(), height: context.height(), strokeWidth: @spec.strokeWidth, stroke: @spec.stroke })
    @presentable(this, border)


exports.CanvasBorder = CanvasBorder

