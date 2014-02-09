Stimulus = require("../stimresp").Stimulus


class Group extends Stimulus

  constructor: (@stims, layout) ->
    super({})

    if layout
      @layout = layout
      for stim in @stims
        stim.layout = layout

  render: (context, layer) ->
    for stim in @stims
      stim.render(context, layer)


exports.Group = Group



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

