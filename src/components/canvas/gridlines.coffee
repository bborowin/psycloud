Kinetic = require("../../../jslibs/kinetic").Kinetic
KStimulus = require("../../stimresp").KineticStimulus


# a set of intersecting lines forming a grid on the canvas
class GridLines extends KStimulus

  defaults:
    x: 0, y: 0, width: null, height: null, rows: 3, cols: 3, stroke: "black", strokeWidth: 2, dashArray: null

  # Construct a new GridLines.
  #
  # @param [Object] spec component parameters
  # @option options [Int] strokeWidth the thickness of the crosshair lines
  # @option options [Int] length the length of the lines
  # @option options [String] fill the color of the lines
  constructor: (spec = {}) ->
    super(spec)

  render: (context) ->
    if not @spec.height?
      height = context.height()
    else
      height = @spec.height
    if not @spec.width?
      width = context.width()
    else
      width = @spec.width

    group = new Kinetic.Group()

    for i in [0..@spec.rows]
      y = @spec.y + (i * height / @spec.rows)
      line = new Kinetic.Line({
        points: [@spec.x, y, @spec.x + width, y]
        stroke: @spec.stroke
        strokeWidth: @spec.strokeWidth
        dashArray: @spec.dashArray
      })

      group.add(line)

    for i in [0..@spec.cols]
      x = @spec.x + (i * width / @spec.cols)
      line = new Kinetic.Line({
        points: [x, @spec.y, x, @spec.y + height]
        stroke: @spec.stroke
        strokeWidth: @spec.strokeWidth
        dashArray: @spec.dashArray
      })

      group.add(line)

    @presentable(group)




exports.GridLines = GridLines