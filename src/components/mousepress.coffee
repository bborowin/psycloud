Q = require("q")
Response = require("../stimresp").Response
utils = require("../utils")

class MousePress extends Response

  activate: (context) ->
    @startTime = utils.getTimestamp()
    myname = @name
    deferred = Q.defer()
    mouse = context.mousepressStream()
    mouse.stream.take(1).onValue((event) =>
      timestamp = utils.getTimestamp()
      mouse.stop()

      resp =
        name: myname
        id: @id
        KeyTime: timestamp
        RT: timestamp - @startTime
        Accuracy: Acc

      context.pushData(resp)


      deferred.resolve(event))
    deferred.promise

exports.MousePress = MousePress