utils = require("../utils")
Q = require("q")
Response = require("../stimresp").Response
ResponseData = require("../stimresp").ResponseData

class Receiver extends Response

  defaults:
    id: ""

  activate: (context, stimulus) ->
    super(context, stimulus)
    console.log("listening for", @spec.id, "on", stimulus)
    console.log("stimulus has on method", stimulus.on)
    deferred = Q.defer()


    stimulus.on(@spec.id, (args) =>
      console.log("received event", @spec.id, "with args ", args)
      resp =
        name: "Receiver"
        id: @spec.id
      deferred.resolve(new ResponseData(resp)))

    deferred.promise


exports.Receiver = Receiver