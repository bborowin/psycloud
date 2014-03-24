Stimulus = require("../stimresp").Stimulus
Timeout = require("./timeout").Timeout
Presentable = require("../stimresp").Presentable
Q = require("q")
utils = require("../utils")
_ = require("lodash")

class Sequence extends Stimulus


  # Construct a new Sequence stimulus.
  #
  # @param [Array] stims an array of stimulus elements
  # @param [Number] soa an array of stimulus onset asychrony values. This array represents the successive temporal delays between stimuli.
  # @param [Boolean] clear whether the canvas should be cleared after each stimulus presentation.
  # @param [Number] times the number of times to present the enitire sequence (default = 1)
  constructor: (@stims, @soa, @clear = true, @times = 1) ->
    super({})
    if (@soa.length != @stims.length)
      @soa = utils.repLen(@soa, @stims.length)

    @onsets = for i in [0...@soa.length]
      _.reduce(@soa[0..i], (x, acc) -> x + acc)


  genseq: (context) ->
    deferred = Q.defer()
    _.forEach([0...@stims.length], (i) =>
      ev = new Timeout({duration: @onsets[i]})
      stim = @stims[i]

      ev.activate(context).then(=>
        if not @stopped
          if @clear
            context.clearContent()

          p = stim.render(context)
          p.present(context)
          context.draw()

          if i == @stims.length - 1
            deferred.resolve(1)
      )
    )

    deferred.promise


  render: (context) ->
    {
      present: (context) =>
        result = Q.resolve(0)
        for i in [0...@times]

          result = result.then(=>
            @genseq(context)
          )

        result.then(=>
          context.clearContent()
        )
    }



exports.Sequence = Sequence

