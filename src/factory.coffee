
_ = require('lodash')
didyoumean = require("didyoumean")
didyoumean.caseSensitive = true

Canvas = require("./components/canvas/canvas").Canvas
Html = require("./components/html/html").Html
Components = require("./components/components")
Psy = require("./psycloud")
Layout = require("./layout")
AutoResponse = require("./stimresp").AutoResponse



class ComponentFactory

  @transformPropertySpec: (name, params) ->
    sname = name.split("$")
    if sname.length is 1
      name = sname[0]
    else if sname.length is 2
      name = sname[0]
      id = sname[1]
      params.id = id
    else
      throw new Error("Illegal property name #{name}. Can only have one '$' character in name")

    [name, params]


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
    stimSpec = _.omit(spec, "Next")

    if spec.Next?
      responseSpec = _.pick(spec, "Next")
      response = @buildResponse(responseSpec.Next)
    else
      response = new AutoResponse()

    stim = @buildStimulus(stimSpec)

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


spec =
  Blank:
    file: "red"

[name, params] = ComponentFactory.transformPropertySpec(_.keys(spec)[0], _.values(spec)[0])
console.log(name, params)

exports.ComponentFactory = ComponentFactory

class DefaultComponentFactory extends ComponentFactory

  constructor: ->
    @registry = _.merge(Components, Canvas, Html)


  makeStimSet: (params, callee, registry) ->
    names = _.keys(params)
    props = _.values(params)

    stims = _.map([0...names.length], (i) =>
      callee(names[i], props[i], registry)
    )

  makeNestedStims: (params, callee, registry) ->
    names = _.map(params, (stim) -> _.keys(stim)[0])
    props = _.map(params, (stim) -> _.values(stim)[0])

    stims = _.map([0...names.length], (i) =>
      callee(names[i], props[i], registry)
    )


  make: (name, params, registry) ->
    callee = arguments.callee
    [name, params] = ComponentFactory.transformPropertySpec(name, params)


    switch name
      when "Group"
        stims = @makeNestedStims(params.stims, callee, @registry)

        if params.layout?
          layoutName = _.keys(params.layout)[0]
          layoutParams = _.values(params.layout)[0]
          new Components.Group(stims, @makeLayout(layoutName, layoutParams, context), params)
        else
          new Components.Group(stims, null, params)

      when "CanvasGroup"
        stims = @makeNestedStims(params.stims, callee, @registry)

        if params.layout?
          layoutName = _.keys(params.layout)[0]
          layoutParams = _.values(params.layout)[0]
          new Components.CanvasGroup(stims, @makeLayout(layoutName, layoutParams, context), params)
        else
          new Components.CanvasGroup(stims, null, params)

      when "Grid"
        stims = @makeNestedStims(params.stims, callee, @registry)
        new Components.Grid(stims, params.rows or 3, params.columns or 3, params.bounds or null)

      when "Background"
        stims = @makeStimSet(params, callee, @registry)
        new Canvas.Background(stims)

      when "First"
        resps = @makeNestedStims(params, callee, @registry)

        new Components.First(resps)
      else
        if not registry[name]?
          throw new Error("DefaultComponentFactory: cannot find component named: " + name + "-- did you mean? " + didyoumean(name, _.keys(registry)) + "?")
        new registry[name](params)

  makeStimulus: (name, params) ->
    console.log("making stimulus", name, "with params", params)
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
