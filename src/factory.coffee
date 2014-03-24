
_ = require('lodash')

Canvas = require("./components/canvas/canvas").Canvas
Html = require("./components/html/html").Html
Components = require("./components/components")
Psy = require("./psycloud")
Layout = require("./layout")


class ComponentFactory

  constructor: (@context) ->

  buildStimulus: (spec) ->
    stimType = _.keys(spec)[0]
    params = _.values(spec)[0]
    @makeStimulus(stimType, params)

  buildResponse: (spec) ->
    responseType = _.keys(spec)[0]
    params = _.values(spec)[0]
    @makeResponse(responseType, params)

  buildEvent: (spec) ->
    if not spec.Next?
      console.log("error building event with spec: ", spec)
      throw new Error("Event specification does not contain 'Next' element")

    stimSpec = _.omit(spec, "Next")
    responseSpec = _.pick(spec, "Next")

    stim = @buildStimulus(stimSpec)
    response = @buildResponse(responseSpec.Next)
    @makeEvent(stim, response)

  make: (name, params, registry) ->
    throw new Error("unimplemented", name, params, registry)


  makeStimulus: (name, params) ->
    throw new Error("unimplemented", name, params)

  makeResponse: (name, params) ->
    throw new Error("unimplemented", name, params)

  makeEvent: (stim, response) ->
    throw new Error("unimplemented", stim, response)

  makeLayout: (name, params, context) ->
    throw new Error("unimplemented", name, params, context)



exports.ComponentFactory = ComponentFactory

class DefaultComponentFactory extends ComponentFactory

  constructor: ->
    @registry = _.merge(Components, Canvas, Html)


  make: (name, params, registry) ->
    callee = arguments.callee

    switch name
      when "Group"

        names = _.map(params.stims, (stim) -> _.keys(stim)[0])
        props = _.map(params.stims, (stim) -> _.values(stim)[0])
        stims = _.map([0...names.length], (i) =>
          callee(names[i], props[i], @registry)
        )

        if params.layout?
          layoutName = _.keys(params.layout)[0]
          layoutParams = _.values(params.layout)[0]
          new Components.Group(stims, @makeLayout(layoutName, layoutParams, context))
        else
          new Components.Group(stims)

      when "Grid"
        names = _.map(params.stims, (stim) -> _.keys(stim)[0])
        props = _.map(params.stims, (stim) -> _.values(stim)[0])
        stims = _.map([0...names.length], (i) =>
          callee(names[i], props[i], @registry)
        )

        new Components.Grid(stims, params.rows or 3, params.columns or 3, params.bounds or null)


      when "Background"
        console.log("building background", params)
        names = _.keys(params)
        props = _.values(params)
        console.log("names", names)
        console.log("props", props)
        stims = _.map([0...names.length], (i) =>
          callee(names[i], props[i], @registry)
        )

        new Canvas.Background(stims)

      when "First"
        names = _.keys(params)
        props = _.values(params)

        resps = _.map([0...names.length], (i) =>
          callee(names[i], props[i], @registry)
        )
        new Components.First(resps)
      else
        if not registry[name]?
          console.log("registry is", registry)
          throw new Error("DefaultComponentFactory:make cannot find component in registry named: ", name)
        new registry[name](params)

  makeStimulus: (name, params) ->
    @make(name, params, @registry)

  makeResponse: (name, params) ->
    @make(name, params, @registry)

  makeEvent: (stim, response) -> new Psy.Event(stim, response)

  makeLayout: (name, params, context) ->
    switch name
      when "Grid"
        new Layout.GridLayout(params[0], params[1], {x: 0, y: 0, width: context.width(), height: context.height()})
      else
        console.log("unrecognized layout", name)


exports.DefaultComponentFactory = DefaultComponentFactory
exports.componentFactory = new DefaultComponentFactory()

console.log("exports.DefaultComponentFactory", DefaultComponentFactory)