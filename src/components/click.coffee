Q = require("q")
Response = require("../stimresp").Response


class Click extends Response

  defaults:
    id: null
    name: null


  activate: (context) ->

    ## should be able to handle Kinetic object or html element
    if @spec.id?
      node = "#" + @spec.id
    else if @spec.name?
      node = "." + @spec.name

    element = context.stage.get("." + node)

    if not element
      throw new Error("cannot find element:" + @node)

    deferred = Q.defer()

    element.on "click", (ev) =>
      deferred.resolve(ev)

    deferred.promise

exports.Click = Click