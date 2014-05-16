utils = require("../utils")
Q = require("q")
Response = require("../stimresp").Response
ResponseData = require("../stimresp").ResponseData

class Receiver extends Response

  defaults:
    id: ""

  activate: (context, stimulus) ->
    super(context, stimulus)
    deferred = Q.defer()

    stimulus.on(@spec.id, (args) =>
      console.log("received event", @spec.id, "with args ", args)
      resp =
        name: "Receiver"
        id: @spec.id
      deferred.resolve(new ResponseData(resp)))

    deferred.promise


exports.Receiver = Receiver