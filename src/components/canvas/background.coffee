Kinetic = require("../../../jslibs/kinetic").Kinetic
GStimulus = require("../../stimresp").GraphicalStimulus
KineticDrawable = require("../../stimresp").KineticDrawable
ContainerDrawable = require("../../stimresp").ContainerDrawable
_ = require("lodash")

class Background extends GStimulus

  constructor: (@stims = [], @fill = "white") ->
    super({}, {})
    if not _.isArray(@stims)
      @stims = [@stims]

  render: (context) ->
    background = new Kinetic.Rect({
      x: 0,
      y: 0,
      width: context.width(),
      height: context.height(),
      name: 'background'
      fill: @fill
    })

    drawables = []
    drawables.push(new KineticDrawable(background))



    for stim in @stims
      drawables.push(stim.render(context))

    new ContainerDrawable(drawables)



exports.Background = Background