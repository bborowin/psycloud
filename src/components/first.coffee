_ = require('lodash')
Q = require("q")
Response = require("../stimresp").Response


class First extends Response
  constructor: (@responses) ->
    super({})

  #start: (context) -> @activate(context)

  activate: (context, stimulus) ->
    _done = false
    deferred = Q.defer()
    _.forEach(@responses, (resp) =>
      resp.activate(context).then( (obj) =>

        if not _done
          console.log("resolving response", obj)
          deferred.resolve(obj)
          _done = true
        else
          console.log("not resolving, already done")
      )
    )

    deferred.promise


exports.First = First