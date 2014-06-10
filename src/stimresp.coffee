_ = require('lodash')
lay = require("./layout")
#Kinetic = require("../jslibs/kinetic")
signals = require("smokesignals")
Q = require("q")

{match} = require 'coffee-pattern'


exports.Reaction =
class Reaction


  #parseSelectorString: (sel) ->
  #  if sel.startsWith("#")
  #    {
  #      id: sel.from(1)
  #    }
  #  else if

  constructor: (@signal, @callback, @id=null) ->

  bind: (node) ->
    if @id?
      ""




###
  Routines:
    prelude:
      ---
    trial: ->
      design injected
      ---
    trial2: ->
      design


###




exports.Component =
class Component


  standardDefaults: { }

  defaults: { }

  signals: []

  hasChildren: -> false

  getChildren: -> []

  constructor: (spec={}) ->
    signals.convert(this)
    @spec = _.defaults(spec, @defaults)
    @spec = _.defaults(spec, @standardDefaults)
    @spec = _.omit(@spec, (value, key) -> not value?)

    @name = @constructor.name

    @initialize()

  initialize: ->

  start: (context) ->

  stop: (context) ->

exports.Stimulus =
class Stimulus extends exports.Component

  standardDefaults: { react: {} }

  constructor: (spec={}) ->
    super(spec)


  initialize: ->
    if @spec?.id?
      @id = @spec.id
    else
      @id = _.uniqueId("stim_")

    @stopped = false

    @react = @spec.react or {}

  initReactions: (self) ->
    for key, value of @react
      if _.isFunction(value)
        @addReaction(key,value)
      else
        @addReaction(key, value.callback, value.selector)

  addReaction: (name, fun, selector) ->
    # TODO check that "name" is a valid signal
    if not selector?
      this.on(name,fun)
    else
      if selector.id is this.id
        this.on(name,fun)
      else if @hasChildren()
        for child in @getChildren()
          child.addReaction(name, fun, selector)


  get: (name) -> @spec[name]

  set: (name, value) -> @spec[name] = value

  reset: -> @stopped = false

  render: (context, layer) ->

  start: (context) ->
    p = @render(context)
    p.present(context)
    context.draw()


  stop: (context) -> @stopped = true


  #id: -> @spec.id or _.uniqueId()

exports.GraphicalStimulus =
class GraphicalStimulus extends exports.Stimulus

  standardDefaults: { x:0, y:0, origin: "top-left"}

  constructor: (spec={}) ->
    if spec.layout?
      @layout = spec.layout
    else
      @layout =  new lay.AbsoluteLayout()

    @overlay =  false

    super(spec)


  drawable: (knode) -> (context) -> console.log("GraphicalStimulus: drawable, no op")

  toPixels: (arg, dim) -> lay.toPixels(arg,dim)

  xyoffset: (origin, nodeWidth, nodeHeight) ->
    switch origin
      when "center" then [-nodeWidth/2, -nodeHeight/2]
      when "center-left" or "left-center" then [0, -nodeHeight/2]
      when "center-right" or "right-center" then [-nodeWidth,-nodeHeight/2]
      when "top-left" or "left-top" then [0,0]
      when "top-right" or "right-top" then [-nodeWidth,0]
      when "top-center" or "center-top" then [-nodeWidth/2,0]
      when "bottom-left" or "left-bottom" then [0,-nodeHeight]
      when "bottom-right" or "right-bottom" then [-nodeWidth,-nodeHeight]
      when "bottom-center" or "center-bottom" then [-nodeWidth/2,-nodeHeight]
      else
        throw new Error("failed to match 'origin' argument:", origin)

  computeCoordinates: (context, position, nodeWidth=0, nodeHeight=0) ->
    xy = if position?
      @layout.computePosition([context.width(), context.height()], position)
    else if @spec.x? and @spec.y?
      [@layout.convertToCoordinate(@spec.x, context.width()), @layout.convertToCoordinate(@spec.y, context.height())]
    else throw new Error("computeCoordinates: either position or x,y coordinates must be defined")

    if @spec.origin?
      xyoff = @xyoffset(@spec.origin, nodeWidth, nodeHeight)
      xy[0] = xy[0] + xyoff[0]
      xy[1] = xy[1] + xyoff[1]
    xy

  width: -> 0

  height: -> 0

  bounds: -> { x: 0, y: 0, width: 0, height: 0}



class KineticStimulus extends exports.GraphicalStimulus

  presentable: (parent, node, onPresent) ->
    new KineticDrawable(parent, node, onPresent)

  @nodeSize: (node) ->
    if node.getClassName() == "Group"
      KineticStimulus.groupSize(node)
    else
      { width: node.getWidth(), height: node.getHeight() }

  @nodePosition: (node) ->
    if node.getClassName() == "Group"
      xb = KineticStimulus.groupXBounds(node)
      yb = KineticStimulus.groupYBounds(node)
      { x: xb[0], y: yb[0] }
    else
      { x: node.getX(), y: node.getY() }

  @groupSize: (group) ->
    xb = @groupXBounds(group)
    yb = @groupYBounds(group)

    { width: xb[1] - xb[0], height: yb[1] - yb[0] }

  @groupXBounds: (group) ->
    children = group.getChildren()
    xmin = Number.MAX_VALUE
    xmax = -1

    for i in [0...children.length]
      pos = children[i].getAbsolutePosition()
      if pos.x < xmin
        xmin = pos.x
      if pos.x + children[i].getWidth() > xmax
        xmax = pos.x + children[i].getWidth()

    [xmin, xmax]

  @groupYBounds: (group) ->
    children = group.getChildren()
    ymin = Number.MAX_VALUE
    ymax = -1
    for i in [0...children.length]
      pos = children[i].getAbsolutePosition()
      if pos.y < ymin
        ymin = children[i].getY()
      if pos.y + children[i].getHeight() > ymax
        ymax = pos.y + children[i].getHeight()

    [ymin,ymax]


  @groupPosition: (group) ->
    children = group.getChildren()
    if children.length == 0
      { x : 0, y: 0 }
    else
      x = Number.MAX_VALUE
      y = -1
      pos = children[i].getAbsolutePosition()
      for i in [0...children.length]
        if pos.x < x
          x = pos.x
        if pos.y < y
          y = pos.y

      { x: x + group.getX(), y: y + group.getY() }



exports.Presentable =
class Presentable

  present: (context) ->

exports.ActionPresentable =
class ActionPresentable extends exports.Presentable

  constructor: (@action) ->
    console.log("constructiong action presentable, action is", @action)

  present: (context) ->
    console.log("inside action presentable, context is", context, "action is", @action)
    @action(context)


exports.Drawable =
class Drawable extends exports.Presentable

  present: (context) ->

  x: -> 0

  y: -> 0

  width: -> 0

  height: -> 0

  bounds: -> { x: @x(), y: @y(), width: @width(), height: @height() }

exports.KineticDrawable =
class KineticDrawable extends exports.Drawable

  # first argument is @context?
  # drawable "renders" the node.
  # drawable
  constructor: (@parent, @node, @onPresent) ->
    # all nodes must be of type "Kinetic.Node"

  addListeners: (context) ->
    eventTypes = ["click", "mouseover", "mousedown", "mouseenter", "mouseleave", "mousemove", "mousedown", "mouseup", "dblclick", "dragstart", "dragend"]
    outer =  this
    for e in eventTypes
      if @parent.spec[e]?
        callback = @parent.spec[e]
        @node.on(e, (evt) =>
          callback(outer, context, evt)
        )


  find: (selector) -> @node.find(selector)


  present: (context, layer) ->
    @addListeners(context)
    if not layer?
      context.contentLayer.add(@node)
    else
      layer.add(@node)

    if @onPresent?
      @onPresent(context)

  set: (name, value) -> @node[name](value)

  x: -> KineticStimulus.nodePosition(@node).x

  y: -> KineticStimulus.nodePosition(@node).y

  xmax: -> KineticStimulus.nodePosition(@node).x + KineticStimulus.nodeSize(@node).width

  ymax: -> KineticStimulus.nodePosition(@node).y + KineticStimulus.nodeSize(@node).height


  width: -> @xmax() - @x()

  height: -> @ymax() - @y()



exports.ContainerDrawable =
class ContainerDrawable extends exports.Drawable

    constructor: (@nodes) ->
      console.log("creating container drawable")

    present: (context, layer) ->
      for node in @nodes
        if not layer
          node.present(context)
        else
          node.present(context, layer)

exports.Response =
class Response extends exports.Stimulus

  start: (context, stimulus) ->
    @activate(context, stimulus)

  activate: (context, stimulus) ->
    console.log("Response.activate", context, stimulus)

exports.AutoResponse =
class AutoResponse extends exports.Response

  activate: (context, stimulus) ->
    Q({})

exports.ResponseData =
class ResponseData

  constructor: (@data) ->


exports.KineticStimulus = KineticStimulus
