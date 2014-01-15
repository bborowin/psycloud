utils = require("../utils")
Q = require("q")
Response = require("../stimresp").Response


class Timeout extends Response

  defaults:
    duration: 1000

  activate: (context) ->
    deferred = Q.defer()

    utils.doTimer(@spec.duration, (diff) =>
      console.log("resolving timeout")
      resp =
        name: "Timeout"
        id: @id
        timeElapsed: diff
        timeRequested: @spec.duration

      context.pushData(resp)
      deferred.resolve(resp))
    deferred.promise


exports.Timeout = Timeout