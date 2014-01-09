_ = require('lodash')
Q = require("q")
TAFFY = require("taffydb").taffy
utils = require("./utils")
DataTable = require("./datatable").DataTable
#Bacon = require("./lib/Bacon").Bacon
Bacon = require("baconjs")
#KineticStimFactory = require("./elements").KineticStimFactory
DefaultComponentFactory = require("./components/factory").DefaultComponentFactory
Background = require("./components/canvas/background").Background
Kinetic = require("../jslibs/kinetic").Kinetic
Stimulus = require("./stimresp").Stimulus
Response = require("./stimresp").Response

exports.EventData =
class EventData
  constructor: (@name, @id, @data) ->

exports.EventDataLog =
class EventDataLog
  constructor: ->
    @eventStack = []

  push: (ev) ->
    @eventStack.push(ev)

  last: ->
    if @eventStack.length < 1
      throw "EventLog is Empty, canot access last element"
    @eventStack[@eventStack.length-1].data

  findAll: (id) ->
    _.filter(@eventStack, (ev) -> ev.id == id)


  findLast: (id) ->
    len = @eventStack.length - 1
    for i in [len .. 0]
      return @eventStack[i] if @eventStack[i].id is id




exports.StimFactory =
  class StimFactory

    buildStimulus: (spec, context) ->

      stimType = _.keys(spec)[0]
      params = _.values(spec)[0]
      @makeStimulus(stimType, params, context)

    buildResponse: (spec, context) ->
      responseType = _.keys(spec)[0]
      params = _.values(spec)[0]

      @makeResponse(responseType, params, context)

    buildEvent: (spec, context) ->
      if not spec.Next?
        throw new Error("Event specification does not contain 'Next' element")
      stimSpec = _.omit(spec, "Next")
      responseSpec = _.pick(spec, "Next")

      stim = @buildStimulus(stimSpec, context)
      response = @buildResponse(responseSpec.Next, context)
      @makeEvent(stim, response, context)

    makeStimulus: (name, params,context) -> throw "unimplemented"

    makeResponse: (name, params, context) -> throw "unimplemented"

    makeEvent: (stim, response, context) -> throw "unimplemented"


exports.MockStimFactory =
  class MockStimFactory extends StimFactory
    makeStimulus: (name, params, context) ->
      ret = {}
      ret[name] = params
      ret

    makeResponse: (name, params, context) ->
      ret = {}
      ret[name] = params
      ret

    makeEvent: (stim, response, context) ->
      [stim, response]



class RunnableNode

  constructor: (@children) ->

  @functionList: (nodes, context, callback) ->
    ## for every runnable node, create a function that returns a promise via 'node.start'
    _.map(nodes, (node) => (=>
      callback(node) if callback?
      node.start(context)
    ))


  before: (context) ->
    -> 0


  after: (context) ->
    -> 0


  @chainFunctions: (funArray) ->
    ## start with a dummy promise
    result = Q.resolve(0)

    ## sequentially chain the promise-producing functions in an array 'funArray'
    ## 'result' is the promise chain.
    for fun in funArray
      result = result.then(fun,
      (err) ->
        throw new Error("Error during execution: ", err)
      )
    result

  numChildren: -> @children.length

  length: -> @children.length

  start: (context) ->
    farray = RunnableNode.functionList(@children, context,
    (node) ->
      console.log("node done", node)
    )

    RunnableNode.chainFunctions(_.flatten([@before(context), farray, @after(context)]))


  stop: (context) ->

exports.RunnableNode = RunnableNode

exports.Event =
  class Event extends RunnableNode

    constructor: (@stimulus, @response) ->
      super([@response])

    stop: (context) ->
      @stimulus.stop(context)
      @response.stop(context)


    before: (context) ->
      =>
        self = this

        if not context.exState.inPrelude
          context.updateState( =>
            context.exState.nextEvent(self)
          )

        if not @stimulus.overlay
          context.clearContent()

        @stimulus.render(context, context.contentLayer)
        context.draw()

    after: (context) ->
      =>
        @stimulus.stop(context)


    start: (context) ->
      super(context)


exports.Trial =
  class Trial extends RunnableNode
    constructor: (events = [], @record={}, @feedback, @background) ->
      super(events)

    numEvents: ->
      @children.length

    push: (event) -> @children.push(event)

    before: (context) ->
      =>
        self = this
        context.updateState( =>
          context.exState.nextTrial(self)
        )

        context.clearBackground()

        if @background?
          context.setBackground(@background)
          context.drawBackground()


    after: (context, callback) ->
      ## return a function that executes feedback operation
      =>
        if @feedback?
          args = context.trialData()
          spec = @feedback.apply(args)
          event = context.stimFactory.buildEvent(spec, context)
          event.start(context).then(=>
            if callback?
              callback()
          )
        else
          Q.fcall(=>
            if callback?
              callback()
          )

    start: (context, callback) ->

      farray = RunnableNode.functionList(@children, context,
        (event) ->
          #console.log("event callback", event)
      )

      RunnableNode.chainFunctions(_.flatten([@before(context), farray, @after(context, callback)]))


    stop: (context) -> #ev.stop(context) for ev in @events


exports.Block =
  class Block extends RunnableNode
    constructor: (children, @blockSpec) ->
      super(children)


    showEvent: (spec, context) ->
      event = buildEvent(spec, context)
      event.start(context)

    before: (context) ->
      self = this
      =>

        context.updateState( =>
          context.exState.nextBlock(self)
        )

        if @blockSpec? and @blockSpec.Start
          spec = @blockSpec.Start(context)
          @showEvent(spec, context)
        else
          Q.fcall(0)



    after: (context) ->
      =>

        if @blockSpec? and @blockSpec.End
          spec = @blockSpec.End(context)
          @showEvent(spec, context)
        else
          Q.fcall(0)


    #after: (context) ->

exports.BlockSeq =
  class BlockSeq extends RunnableNode
    constructor: (children) -> super(children)

exports.Prelude =
  class Prelude extends RunnableNode
    constructor: (children) -> super(children)

    before: (context) ->
      =>
        context.updateState( =>
          context.exState.insidePrelude()
        )

    after: (context) ->
      =>
        context.updateState( =>
          context.exState.outsidePrelude()
        )




exports.ExperimentState =
  class ExperimentState

    constructor: () ->
      @inPrelude = false
      @trial = {}
      @block = {}
      @event = {}
      @blockNumber = 0
      @trialNumber = 0
      @eventNumber = 0

      @stimulus = {}
      @response = {}


    insidePrelude: ->
      ret = $.extend({}, this)
      ret.inPrelude = true
      ret

    outsidePrelude: ->
      ret = $.extend({}, this)
      ret.inPrelude = false
      ret

    nextBlock: (block) ->
      ret = $.extend({}, this)
      ret.blockNumber = @blockNumber + 1
      ret.block = block
      ret

    nextTrial: (trial) ->
      ret = $.extend({}, this)
      ret.trial = trial
      ret.trialNumber = @trialNumber + 1
      ret

    nextEvent: (event) ->
      ret = $.extend({}, this)
      ret.event = event
      ret.eventNumber = @eventNumber + 1
      ret

    toRecord: ->
      ret = {
        $blockNumber: @blockNumber
        $trialNumber: @trialNumber
        $eventNumber: @eventNumber
        $stimulus: @event?.stimulus?.constructor?.name
        $response: @event?.response?.constructor?.name
        $stimulusID: @event?.stimulus?.id
        $responseID: @event?.response?.id

      }

      if not _.isEmpty(@trial) and @trial.record?
        for key, value of @trial.record
          ret[key] = value
      ret



createContext = (id="container") ->
  stage = new Kinetic.Stage(
    container: id
    width: $("#" + id).width()
    height: $("#" + id).height()
  )

  new KineticContext(stage)

exports.createContext = createContext


###
  class UserData
  constructor: ->
    @userData = TAFFY({})

  blockData: (blockNum=null) ->
    if not blockNum?
      blockNum = @exState.blockNumber

    @userData.filter({ blockNumber: blockNum })
###


#exports.UserData = UserData

exports.ExperimentContext =
  class ExperimentContext
    constructor: (stimFactory) ->

      @stimFactory = stimFactory

      @userData = TAFFY({})

      @exState = new ExperimentState()

      @eventData = new EventDataLog()

      @log = []

      @trialNumber = 0

      @currentTrial =  new Trial([], {})

    updateState: (fun) ->
      @exState = fun(@exState)
      @exState

    pushData: (data, withState=true) ->
      if withState
        record = _.extend(@exState.toRecord(), data)
      else
        record = data

      @userData.insert(record)



    logEvent: (key, value) ->

      record = _.clone(@currentTrial.record)
      record[key] = value
      @log.push(record)
      console.log(@log)

    trialData: ->
      ret = @userData().filter({ $trialNumber: @exState.trialNumber }).get()
      if ret.length == 1
        ret[0]
      else ret


    blockData: (args={blockNum: null, name: null}) ->
      if not args.blockNum?
        args.blockNum = @exState.blockNumber

      if not args.name
        @userData().filter({ $blockNumber: args.blockNum })
      else
        @userData().filter({ $blockNumber: args.blockNum }).select(args.name)

    allData: (args= {name: null}) ->
      if not args.name
        @userData()
      else
        @userData().select(args.name)




    showEvent: (event) -> event.start(this)

    showStimulus: (stimulus) -> stimulus.render(this)

    start: (blockList) ->
      try
        farray = RunnableNode.functionList(blockList, this,
          (block) ->
            console.log("block callback", block)
        )

        #@trialNumber += 1
        #@currentTrial = trial
        #trial.start(this)

        RunnableNode.chainFunctions(farray)

      catch error
        console.log("caught error:", error)

      #result.done()


    clearContent: ->

    clearBackground: ->


    keydownStream: -> Bacon.fromEventTarget(window, "keydown")

    keypressStream: -> Bacon.fromEventTarget(window, "keypress")

    mousepressStream: ->

    draw: ->

    insertHTMLDiv: ->
      $("canvas").css("position", "absolute")
      #$(".kineticjs-content").css("position", "absolute")


      $("#container" ).append("""
        <div id="htmlcontainer" class="htmllayer"></div>
      """)

      $("#htmlcontainer").css(
        position: "absolute"
        "z-index": 999
        outline: "none"
        padding: "5px"
      )

      $("#container").attr("tabindex", 0)
      $("#container").css("outline", "none")
      #$("#container").css("padding", "5px")


    clearHtml: ->
      $("#htmlcontainer").empty()
      $("#htmlcontainer").hide()

    appendHtml: (input) ->
      $("#htmlcontainer").addClass("htmllayer")
      $("#htmlcontainer").append(input)
      $("#htmlcontainer").show()

    hideHtml: ->
      $("#htmlcontainer").hide()
      #$("#htmlcontainer").empty()



class KineticContext extends exports.ExperimentContext

  constructor: (@stage) ->
    super(new DefaultComponentFactory())
    @contentLayer = new Kinetic.Layer({clearBeforeDraw: true})
    @backgroundLayer = new Kinetic.Layer({clearBeforeDraw: true})
    @background = new Background([], fill: "white")

    @stage.add(@backgroundLayer)
    @stage.add(@contentLayer)

    @insertHTMLDiv()

  insertHTMLDiv: ->
    super
    $(".kineticjs-content").css("position", "absolute")


  setBackground: (newBackground) ->
    @background = newBackground
    @backgroundLayer.removeChildren()
    @background.render(this, @backgroundLayer)

  drawBackground: ->
    @backgroundLayer.draw()

  clearBackground: ->
    @backgroundLayer.removeChildren()

  clearContent: (draw = false) ->
    #@hideHtml()
    @clearHtml()
    @backgroundLayer.draw()
    @contentLayer.removeChildren()
    if draw
      @draw()


  draw: ->
    $('#container').focus()
    #@background.render(this, @backgroundLayer)
    @contentLayer.draw()
    #@stage.draw()


  width: ->
    @stage.getWidth()

  height: ->
    @stage.getHeight()

  offsetX: ->
    @stage.getOffsetX()

  offsetY: ->
    @stage.getOffsetY()

  showStimulus: (stimulus) -> stimulus.render(this, @contentLayer)


  keydownStream: -> Bacon.fromEventTarget(window, "keydown")

  keypressStream: ->
     #$("body").asEventStream("keypress")
    Bacon.fromEventTarget(window, "keypress")

  mousepressStream: ->
    class MouseBus
      constructor: () ->
        @stream = new Bacon.Bus()

        @handler = (x) =>
          @stream.push(x)

        @stage.on("mousedown", @handler)

      stop: ->
        @stage.off("mousedown", @handler)
        @stream.end()


    new MouseBus()

exports.KineticContext = KineticContext


buildStimulus = (spec, context) ->
  stimType = _.keys(spec)[0]
  params = _.values(spec)[0]
  context.stimFactory.makeStimulus(stimType, params, context)

buildResponse =  (spec, context) ->
  responseType = _.keys(spec)[0]
  params = _.values(spec)[0]
  context.stimFactory.makeResponse(responseType, params, context)

buildEvent = (spec, context) ->
  #if not spec.Next?
  #  throw new Error("Event specification does not contain 'Next' element")

  stimSpec = _.omit(spec, "Next")
  responseSpec = _.pick(spec, "Next")

  if not responseSpec? or _.isEmpty(responseSpec)
    ## in the absence of a 'Next' element, assume stimulus is it's own response
    stim = buildStimulus(stimSpec, context)
    if not stim instanceof Response
      throw new Error("buildEvent: Missing Response from event: ", spec)

    context.stimFactory.makeEvent(stim, stim, context)
  else
    stim = buildStimulus(stimSpec, context)
    response = buildResponse(responseSpec.Next, context)
    context.stimFactory.makeEvent(stim, response, context)


buildTrial = (eventSpec, record, context, feedback, backgroundSpec) ->
  events = for key, value of eventSpec
    context.stimFactory.buildEvent(value)

  if backgroundSpec?
    background = context.stimFactory.buildStimulus(backgroundSpec)
    new Trial(events, record, feedback, background)
  else
    new Trial(events, record, feedback)




buildPrelude = (preludeSpec, context) ->
  events = for key, value of preludeSpec
    stimSpec = _.omit(value, "Next")
    responseSpec = _.pick(value, "Next")

    stim = buildStimulus(stimSpec, context)
    response = buildResponse(responseSpec.Next, context)
    context.stimFactory.makeEvent(stim, response, context)


  new Prelude(events)




exports.Presenter =
class Presenter
  constructor: (@trialList, @display, @context) ->
    @trialBuilder = @display.Trial

    @prelude = if @display.Prelude?
      buildPrelude(@display.Prelude.Events, @context)
    else
      new Prelude([])



  start: () ->

    @blockList = new BlockSeq(for block in @trialList.blocks
      trials = for trialNum in [0...block.length]
        record = _.clone(block[trialNum])
        trialSpec = @trialBuilder.apply(record)
        buildTrial(trialSpec.Events, record, @context, trialSpec.Feedback, trialSpec.Background)
      new Block(trials, @display.Block)
    )

    @prelude.start(@context).then(=> @blockList.start(@context))


# Experiment
# has N parts
# with N blocks
# with N trials

exports.Experiment =
  class Experiment

    #@create: (designSpec, renderer = "Kinetic") ->
    #  switch renderer
    #    when "Kinetic" then new Experiment(designSpec)

    constructor: (@designSpec, @stimFactory = new MockStimFactory()) ->
      @design = new ExpDesign(@designSpec)

      @display = @designSpec.Display

      @trialGenerator = @display.Trial


    buildStimulus: (event, context) ->
      stimType = _.keys(event)[0]
      params = _.values(event)[0]
      @stimFactory.makeStimulus(stimType, params, context)

    buildEvent: (event, context) ->
      responseType = _.keys(event)[0]
      params = _.values(event)[0]
      @stimFactory.makeResponse(responseType, params, context)

    buildTrial: (eventSpec, record, context) ->

      events = for key, value of eventSpec
        stimSpec = _.omit(value, "Next")
        responseSpec = _.pick(value, "Next")

        stim = @buildStimulus(stimSpec)
        response = @buildResponse(responseSpec.Next)
        @stimFactory.makeEvent(stim, response)

      new Trial(events, record)

    start: (context) ->
      #numBlocks = @design.blocks
      trials = @design.fullDesign
      console.log(trials.nrow())
      trialList = for i in [0 ... trials.nrow()]
        record = trials.record(i)
        record.$trialNumber = i
        trialSpec = @trialGenerator(record)
        @buildTrial(trialSpec, record, context)

      context.start(trialList)







    #valueAt: (block, trial) ->
    #  @expanded[block][@name][trial]




exports.letters = ['a','b','c','d','e','d','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']


des = Design:
  Blocks: [
      [
        a:1, b:2, c:3
        a:2, b:3, c:4
      ],
      [
        a:5, b:7, c:6
        a:5, b:7, c:6
      ]

  ]

console.log(des.Blocks)



exports.buildStimulus = buildStimulus
exports.buildResponse = buildResponse
exports.buildEvent = buildEvent
exports.buildTrial = buildTrial
exports.buildPrelude = buildPrelude



