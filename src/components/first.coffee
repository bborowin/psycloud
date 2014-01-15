_ = require('lodash')
Q = require("q")
Response = require("../stimresp").Response


class First extends Response
  constructor: (@responses) ->
    super({})

  activate: (context) ->
    console.log("activating first")
    deferred = Q.defer()
    _.forEach(@responses, (resp) =>
      resp.activate(context).then( (obj) =>
        console.log("resolving response", obj)
        deferred.resolve(obj)))

    deferred.promise


exports.First = First