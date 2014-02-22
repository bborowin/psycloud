Kinetic = require("../../../jslibs/kinetic").Kinetic
KStimulus = require("../../stimresp").KineticStimulus


# A crosshair consisting of intersecting horizontal and vertical lines
class FixationCross extends KStimulus

  defaults:
    strokeWidth: 8, length: 150, fill: 'black'

  # Construct a new FixationCross.
  #
  # @param [Object] spec component parameters
  # @option options [Int] strokeWidth the thickness of the crosshair lines
  # @option options [Int] length the length of the lines
  # @option options [String] fill the color of the lines
  constructor: (spec = {}) ->
    super(spec)

  render: (context) ->
    x = context.width() / 2
    y = context.height() / 2

    horz = new Kinetic.Rect({ x: x - @spec.length / 2, y: y, width: @spec.length, height: @spec.strokeWidth, fill: @spec.fill })
    vert = new Kinetic.Rect({ x: x - @spec.strokeWidth / 2, y: y - @spec.length / 2 + @spec.strokeWidth / 2, width: @spec.strokeWidth, height: @spec.length, fill: @spec.fill })
    group = new Kinetic.Group()
    group.add(horz)
    group.add(vert)
    #layer.add(group)
    @presentable(group)

exports.FixationCross = FixationCross