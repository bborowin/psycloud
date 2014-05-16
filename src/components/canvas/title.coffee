layout = require("../../layout")
#Kinetic = require("../../../jslibs/kinetic").Kinetic
_ = require('lodash')
KStimulus = require("../../stimresp").KineticStimulus


class Title extends KStimulus

  defaults:
    content: "Title", yoffset: 20, fill: "black", fontSize: 80, fontFamily: "Arial", align: "center"

  constructor: (spec = {}) ->
    if (spec.content? and _.isArray(spec.content))
      spec.content = spec.content.join(' \n ')
      if not spec.lineHeight?
        spec.lineHeight = 2
    super(spec)

  initialize: ->
    @text = new Kinetic.Text({
      x: 0,
      y: @spec.yoffset,
      text: @spec.content,
      fontSize: @spec.fontSize,
      fontFamily: @spec.fontFamily,
      fill: @spec.fill
      lineHeight: @spec.lineHeight or 1
      listening: false
      align: @spec.align
      #padding: 20
    })


  render: (context, layer) ->
    @text.setWidth(context.width())
    @presentable(this, @text)



exports.Title = Title