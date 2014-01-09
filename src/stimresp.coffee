_ = require('lodash')
lay = require("./layout")
Module = require("./module").Module


exports.Stimulus =
class Stimulus extends Module

  __standardDefaults: { x:0, y:0, origin: "top-left"}

  defaults: {}

  groupSize: (group) ->
    children = group.getChildren()
    width = 0
    height = 0
    for i in [0...children.length]
      if children[i].getWidth() > width
        width = children[i].getWidth()
      if children[i].getHeight() > height
        height = children[i].getHeight()

    { width: width, height: height }


  constructor: (spec={}) ->
    @spec = _.defaults(spec, @defaults)
    @spec = _.defaults(spec, @__standardDefaults)
    @spec = _.omit(@spec, (value, key) -> not value?)

    @name = @constructor.name

    if @spec?.id?
      @id = @spec.id
    else
      @id = _.uniqueId("stim_")

    @stopped = false

    if @spec.layout?
      @layout = @spec.layout
    else
      @layout =  new lay.AbsoluteLayout()

    @overlay =  false

    @name = this.constructor.name

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

  computeCoordinates: (context, position, nodeWidth=0, nodeHeight=0) ->
    xy = if position
      @layout.computePosition([context.width(), context.height()], position)
    else if @spec.x and @spec.y
      [@layout.convertToCoordinate(@spec.x, context.width()), @layout.convertToCoordinate(@spec.y, context.height())]
    else [0,0]

    if @spec.origin?
      console.log("spec origin",@spec.origin )
      xyoff = @xyoffset(@spec.origin, nodeWidth, nodeHeight)
      console.log("offset!", xyoff)
      xy[0] = xy[0] + xyoff[0]
      xy[1] = xy[1] + xyoff[1]
    xy


  reset: -> @stopped = false

  render: (context, layer) ->

  stop: (context) -> @stopped = true

  #id: -> @spec.id or _.uniqueId()

exports.Response =
class Response extends Stimulus

  start: (context) -> @activate(context)

  activate: (context) ->