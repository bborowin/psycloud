_ = require('lodash')
lay = require("./layout")
Kinetic = require("../jslibs/kinetic")
signals = require("smokesignals")

exports.Stimulus =
class Stimulus


  standardDefaults: { }

  defaults: {}

  constructor: (spec={}) ->
    signals.convert(this)
    @spec = _.defaults(spec, @defaults)
    @spec = _.defaults(spec, @standardDefaults)
    @spec = _.omit(@spec, (value, key) -> not value?)

    @name = @constructor.name

    if @spec?.id?
      @id = @spec.id
    else
      @id = _.uniqueId("stim_")

    @stopped = false
    @name = this.constructor.name
    @initialize()


  initialize: ->

  get: (name) -> @spec[name]

  set: (name, value) -> @spec[name] = value

  reset: -> @stopped = false

  render: (context, layer) ->

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


exports.KineticStimulus =
class KineticStimulus extends exports.GraphicalStimulus

  presentable: (nodes, onPresent) ->
    console.log("creating presentable of", nodes)
    new KineticDrawable(nodes, onPresent)


  @nodeSize: (node) ->
    if node.getClassName() == "Group"
      console.log("class is group!")
      KineticStimulus.groupSize(node)
    else
      { width: node.getWidth(), height: node.getHeight() }

  @nodePosition: (node) ->
    if node.getClassName() == "Group"
      console.log("class is group!")
      xb = KineticStimulus.groupXBounds(node)
      yb = KineticStimulus.groupYBounds(node)
      console.log("xb is", xb)
      console.log("yb is", yb)
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

  constructor: (@nodes, @onPresent) ->
    if not _.isArray(@nodes)
      @nodes = [@nodes]


    # all nodes must be of type "Kinetic.Node"

  present: (context, layer) ->
    console.log("presenting ", @nodes)
    for node in @nodes
      if not layer?
        context.contentLayer.add(node)
      else
        console.log("drawing in layer supplied as arg")
        layer.add(node)

      if @onPresent?
        console.log("calling onPresent!")
        @onPresent(context)

  x: ->
    xs = _.map(@nodes, (node) -> exports.KineticStimulus.nodePosition(node).x)
    _.min(xs)

  y: ->
    ys = _.map(@nodes, (node) -> exports.KineticStimulus.nodePosition(node).y)
    _.min(ys)

  xmax: ->
    xs = _.map(@nodes, (node) -> exports.KineticStimulus.nodePosition(node).x + exports.KineticStimulus.nodeSize(node).width)
    _.max(xs)

  ymax: ->
    xs = _.map(@nodes, (node) -> exports.KineticStimulus.nodePosition(node).y + exports.KineticStimulus.nodeSize(node).height)
    _.max(xs)

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
    console.log("response caputured stimulus", stimulus)
    console.log("calling activate", @activate)
    @activate(context, stimulus)

  activate: (context, stimulus) ->
    console.log("Respnonse.activate", context, stimulus)



exports.ResponseData =
class ResponseData

  constructor: (@data) ->
