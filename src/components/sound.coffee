Stimulus = require("../stimresp").Stimulus
buzz = require("../../jslibs/buzz")

class Sound extends Stimulus

  defaults:
    url: "http://www.centraloutdoors.com/mp3/sheep/sheep.wav"

  constructor: (spec={}) ->
    super(spec)

    @sound = new buzz.sound(@spec.url)

  render: (context, layer) ->
    @sound.play()

exports.Sound = Sound