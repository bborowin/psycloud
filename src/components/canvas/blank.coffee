#Kinetic = require("../../../jslibs/kinetic").Kinetic
KStimulus = require("../../stimresp").KineticStimulus


class Blank extends KStimulus

  defaults:
    fill: "gray", opacity: 1

  render: (context) ->
    blank = new Kinetic.Rect({ x: 0, y: 0, width: context.width(), height: context.height(), fill: @spec.fill, opacity: @spec.opacity })
    @presentable(this, blank)


exports.Blank = Blank






