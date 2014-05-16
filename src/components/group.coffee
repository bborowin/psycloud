Stimulus = require("../stimresp").Stimulus
ContainerDrawable = require("../stimresp").ContainerDrawable
KineticDrawable = require("../stimresp").KineticDrawable
#Kinetic = require("../../jslibs/kinetic").Kinetic
layout = require("../layout")

class Group extends Stimulus

  constructor: (@stims, layout, spec={}) ->
    super(spec)

    console.log("constructing group with stims", stims)

    if layout?
      @layout = layout
      for stim in @stims
        stim.layout = layout

  render: (context) ->
    nodes = for stim in @stims
      stim.render(context)

    new ContainerDrawable(nodes)

exports.Group = Group

class CanvasGroup extends Group

  constructor: (stims, layout, spec={}) ->
    super(stims, layout, spec)
    @group = new Kinetic.Group({id: @spec.id})

    for stim in @stims
      console.log("canvas group stim child", stim)
      #console.log(stim instanceof Kinetic.Node)
      #@group.add(stim)

  render: (context) ->
    console.log("rendering canvas group child nodes", @stims)
    for stim in @stims
      console.log("rendering node for stim", stim)
      node = stim.render(context).node
      console.log("rendered node", node)
      @group.add(node)

    new KineticDrawable(this, @group)



class Grid extends Group

  constructor: (@stims, @rows, @columns, @bounds) ->
    @layout = new layout.GridLayout(@rows, @columns, @bounds)
    for stim in @stims
      stim.layout = @layout


exports.Group = Group
exports.CanvasGroup = CanvasGroup
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

