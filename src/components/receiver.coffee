utils = require("../utils")
Q = require("q")
Response = require("../stimresp").Response
ResponseData = require("../stimresp").ResponseData

class Receiver extends Response

  defaults:
    id: null, signal: ""

  activate: (context, stimulus) ->
    super(context, stimulus)
    deferred = Q.defer()

    callback = (args) =>
      console.log("Reciever callback")
      resp =
        name: "Receiver"
        signal: @spec.signal
        id: @spec.id

      deferred.resolve(new ResponseData(resp))

    if @spec.id?
      stimulus.addReaction(@spec.signal, callback, { id: @spec.id })
    else
      @spec.id = stimulus.id
      console.log("adding reaction for ", @spec.signal)
      stimulus.addReaction(@spec.signal, callback)

    deferred.promise


exports.Receiver = Receiver