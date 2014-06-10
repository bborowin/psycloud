Stimulus = require("../stimresp").Stimulus
ContainerDrawable = require("../stimresp").ContainerDrawable
KineticDrawable = require("../stimresp").KineticDrawable
#Kinetic = require("../../jslibs/kinetic").Kinetic
layout = require("../layout")


class Container extends Stimulus
  constructor: (@children, spec={}) ->
    super(spec)

    #for stim in @stims
    #  for signal in stim.signals
    #    ""
        #stim.on(signal, (args) =>
        #  console.log("forwarding signal", signal, "with args", args)
        #  @emit(signal, args)
        #)

  #addReaction: (name, reaction) ->

  hasChildren: -> true

  getChildren: -> @children


class Group extends Container

  constructor: (children, layout, spec={}) ->
    super(children, spec)

    if layout?
      @layout = layout
      for stim in @children
        stim.layout = layout

  render: (context) ->
    nodes = for stim in @children
      stim.render(context)

    new ContainerDrawable(nodes)

exports.Group = Group

class CanvasGroup extends Group

  constructor: (children, layout, spec={}) ->
    super(children, layout, spec)
    @group = new Kinetic.Group({id: @spec.id})

    for stim in @stims
      console.log("canvas group stim child", stim)
      #console.log(stim instanceof Kinetic.Node)
      #@group.add(stim)

  render: (context) ->
    console.log("rendering canvas group child nodes", @children)
    for stim in @children
      console.log("rendering node for stim", stim)
      node = stim.render(context).node
      console.log("rendered node", node)
      @group.add(node)

    new KineticDrawable(this, @group)



class Grid extends Group

  constructor: (children, @rows, @columns, @bounds) ->
    super(children)
    @layout = new layout.GridLayout(@rows, @columns, @bounds)
    for stim in @children
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

