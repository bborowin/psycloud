utils = require("../utils")
Q = require("q")
Response = require("../stimresp").Response
ResponseData = require("../stimresp").ResponseData

class Timeout extends Response

  defaults:
    duration: 1000

  activate: (context) ->
    deferred = Q.defer()

    utils.doTimer(@spec.duration, (diff) =>
      resp =
        name: "Timeout"
        id: @id
        timeElapsed: diff
        timeRequested: @spec.duration

      deferred.resolve(new ResponseData(resp)))

    deferred.promise


exports.Timeout = Timeout