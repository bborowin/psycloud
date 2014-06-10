layout = require("../../layout")
#Kinetic = require("../../../jslibs/kinetic").Kinetic
_ = require('lodash')
KStimulus = require("../../stimresp").KineticStimulus


class MessageBox extends KStimulus

  defaults:
    content: "Text", x: 5, y: 5, width: 100, background: "green", fill: "black", fontSize: 18, fontFamily: "Arial", align: "center", position: null

  constructor: (spec = {}) ->
    if (spec.content? and _.isArray(spec.content))
      spec.content = spec.content.join(' \n ')
      if not spec.lineHeight?
        spec.lineHeight = 2
    super(spec)

  initialize: ->


    @text = new Kinetic.Text({
      x: 0,
      y: 0,
      text: @spec.content,
      fontSize: @spec.fontSize,
      fontFamily: @spec.fontFamily,
      fill: @spec.fill
      lineHeight: @spec.lineHeight or 1
      width: @spec.width
      listening: false
      align: @spec.align

    })

    @rect = new Kinetic.Rect({
      x: 0,
      y: 0,
      stroke: "black",
      strokeWidth: 2,
      fill: @spec.background,
      width: @spec.width,
      height: @text.height() + 10,
      cornerRadius: 2
    });

    @group = new Kinetic.Group()
    @group.add(@rect)
    @group.add(@text)


  render: (context, layer) ->

    coords = @computeCoordinates(context, @spec.position, @text.getWidth(), @text.getHeight())
    @text.setPosition({x: coords[0], y: coords[1]})
    @rect.setPosition({x: coords[0], y: coords[1] - 5})
    @presentable(this, @group)


exports.MessageBox = MessageBox

