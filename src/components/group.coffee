Stimulus = require("../stimresp").Stimulus
ContainerDrawable = require("../stimresp").ContainerDrawable
layout = require("../layout")

class Group extends Stimulus

  constructor: (@stims, layout) ->
    super({})

    if layout
      @layout = layout
      for stim in @stims
        stim.layout = layout

  render: (context) ->
    nodes = for stim in @stims
      stim.render(context)

    new ContainerDrawable(nodes)



exports.Group = Group


class Grid extends Group

  constructor: (@stims, @rows, @columns, @bounds) ->
    @layout = new layout.GridLayout(@rows, @columns, @bounds)
    for stim in @stims
      stim.layout = @layout



exports.Grid = Grid





#class FlowRight extends Group
#
#  defaults:
#    x: 0, y: 0, gap: 0
#
#  constructor: (@stims) ->
#
#  render: (context, layer) ->
#    for stim in @stims
#      stim.render(context, layer)

