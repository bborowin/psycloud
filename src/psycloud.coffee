_ = require('lodash')
Q = require("q")
TAFFY = require("taffydb").taffy
utils = require("./utils")
DataTable = require("./datatable").DataTable
#Bacon = require("./lib/Bacon").Bacon
Bacon = require("baconjs")
#KineticStimFactory = require("./elements").KineticStimFactory
DefaultComponentFactory = require("./factory").DefaultComponentFactory
Background = require("./components/canvas/background").Background
#Kinetic = require("../jslibs/kinetic").Kinetic
Stimulus = require("./stimresp").Stimulus
Response = require("./stimresp").Response
ResponseData = require("./stimresp").ResponseData
props = require("pathval")
#StateMachine = require("../jslibs/state-machine")


STRIP_COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/g

getParamNames = (func) ->
  fnStr = func.toString().replace(STRIP_COMMENTS, "")
  result = fnStr.slice(fnStr.indexOf("(") + 1, fnStr.indexOf(")")).match(/([^\s,]+)/g)
  result = []  if result is null
  result



class Input

  @EOF: new Input()
  @EMPTY: new Input()

class Iteratee

class Done extends Iteratee
  constructor: (@a, @remaining) ->

class Error extends Iteratee
  constructor: (@msg, @input)  ->

class Cont extends Iteratee
  # cont = input -> iteratee
  constructor: (@cont) ->








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

    makeStimulus: (name, params,context) -> throw new Error("unimplemented")

    makeResponse: (name, params, context) -> throw new Error("unimplemented")

    makeEvent: (stim, response, context) -> throw new Error("unimplemented")


exports.MockStimFactory =
  class MockStimFactory extends exports.StimFactory
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





# TrialEnumerator
# next: (context) -> trial ... a runnable trial
#

class RunnableNode

  @functionList: (nodes, context, callback) ->
    ## for every runnable node, create a function that returns a promise via 'node.start'
    _.map(nodes, (node) -> ( (arg) ->
      context.handleResponse(arg)
      callback(node) if callback?
      node.start(context)
    ))

  @chainFunctions: (funArray) ->
    ## start with a dummy promise
    result = Q.resolve(0)

    ## sequentially chain the promise-producing functions in an array 'funArray'
    ## 'result' is the promise chain.
    for fun in funArray
      result = result.then(fun,
      (err) ->
        console.log("error stack: ", err.stack))
        #throw new Error("Error during execution: ", err)



    result

  constructor: (@children) ->


  before: (context) -> new FunctionNode(-> 0)

  after: (context) -> new FunctionNode(-> 0)

  numChildren: -> @children.length

  length: -> @children.length

  start: (context) ->

    farray = RunnableNode.functionList(_.flatten([@before(context), @children, @after(context)]), context,
    (node) ->
      console.log("node done", node)
    )

    RunnableNode.chainFunctions(farray)


  stop: (context) ->

exports.RunnableNode = RunnableNode


exports.FunctionNode =
class FunctionNode extends RunnableNode

  constructor: (@fun) ->

  start: (context) -> Q.fcall(@fun)

functionNode = (fun) -> new FunctionNode(fun)

exports.FeedbackNode =
class FeedbackNode extends RunnableNode

  constructor: (@feedback) ->

  numChildren: -> 1

  length: -> 1

  start: (context) ->
    if @feedback?
      args = context.trialData().get()
      idSet = {}
      for obj in args
        if obj["id"]?
          idSet[obj["id"]] = obj


      args = _.extend(args, idSet)
      args.context = context
      spec = @feedback.apply(args)
      event = context.stimFactory.buildEvent(spec, context)
      event.start(context)

    else
      Q(0)

exports.Event =
  class Event extends RunnableNode

    constructor: (@stimulus, @response) ->
      node = {
        start: (context) =>
          #@stimulus.start(context).then(@response.start(context))
          @stimulus.start(context)
          @response.start(context,stimulus)
          #context.draw()
          #@response.start(context, stimulus)
      }

      super([node])

    stop: (context) ->
      @stimulus.stop(context)
      @response.stop(context)


    before: (context) ->
      self = this

      functionNode( =>
        if not context.exState.inPrelude
          context.updateState( =>
            context.exState.nextEvent(self)
          )

        if not @stimulus.overlay
          context.clearContent()

        #@stimulus.render(context).present(context)
        #context.draw()
      )

    after: (context) ->
      functionNode( =>
        @stimulus.stop(context)
      )

    #start: (context) -> super(context)


exports.Trial =
  class Trial extends RunnableNode
    constructor: (events = [], @record={}, @feedback, @background) ->
      super(events)

    numEvents: ->
      @children.length

    push: (event) -> @children.push(event)

    before: (context) ->
      self = this
      for child in @children
        console.log("initializing stimulus", child.stimulus)
        # TODO initialize should be removed from constructor call then
        child.stimulus.initialize()


      functionNode ( =>
        context.updateState( =>
          context.exState.nextTrial(self)
        )

        context.clearBackground()

        if @background?
          context.setBackground(@background)
          context.drawBackground()
      )

    after: (context) -> new FeedbackNode(@feedback)

    start: (context, callback) ->

      farray = RunnableNode.functionList(_.flatten([@before(context), @children, @after(context)]), context,
        (event) ->
          console.log("event callback", event)
      )

      RunnableNode.chainFunctions(farray)


    stop: (context) -> #ev.stop(context) for ev in @events


exports.Block =
  class Block extends RunnableNode
    constructor: (children, @blockSpec) ->
      super(children)


    showEvent: (spec, context) ->
      event = context.stimFactory.buildEvent(spec, context)
      event.start(context)

    before: (context) ->
      self = this
      functionNode( =>
        context.updateState( =>
          context.exState.nextBlock(self)
        )

        if @blockSpec? and @blockSpec.Start
          # TODO decide what variables to make available magically
          args = _.extend(context.exState.toRecord(), context: context)
          spec = @blockSpec.Start.apply(args)
          @showEvent(spec, context)
        else
          Q.fcall(0)
      )



    after: (context) ->
      functionNode ( =>
        if @blockSpec? and @blockSpec.End
          blockData = context.blockData()
          ids = _.unique(blockData.select("id"))
          console.log("END ids", ids)
          out = {}

          for curid in ids
            out[curid] = DataTable.fromRecords(blockData.filter(id: curid).get())

          args = _.extend(context.exState.toRecord(), context: context, out)
          console.log("block end args")
          spec = @blockSpec.End.apply(args)
          @showEvent(spec, context)
        else
          Q.fcall(0)
      )




exports.BlockSeq =
  class BlockSeq extends RunnableNode
    constructor: (children) -> super(children)


exports.Prelude =
  class Prelude extends RunnableNode
    constructor: (children) -> super(children)

    before: (context) ->
      functionNode ( =>
        context.updateState( =>
          context.exState.insidePrelude()
        )
      )

    after: (context) ->
      functionNode ( =>
        context.updateState( =>
          context.exState.outsidePrelude()
        )
      )


exports.Coda =
  class Coda extends RunnableNode
    constructor: (children) -> super(children)

    #before: (context) ->
    #  functionNode ( =>
        #context.updateState( =>
          # done
        #)
    #  )

    #after: (context) ->
    #  functionNode ( =>
        #context.updateState( =>
        #  # done
        #)
    #  )








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
        blockNumber: @blockNumber
        trialNumber: @trialNumber
        eventNumber: @eventNumber
        stimulus: @event?.stimulus?.constructor?.name
        response: @event?.response?.constructor?.name
        stimulusID: @event?.stimulus?.id
        responseID: @event?.response?.id

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

      @variables = {}

      @responseQueue = []

      @stimFactory = stimFactory

      @userData = TAFFY({})

      @exState = new ExperimentState()

      @eventData = new EventDataLog()

      @log = []

      @trialNumber = 0

      @currentTrial =  new Trial([], {})

      @numBlocks = 0


    set: (name, value) -> props.set(@variables, name, value)

    get: (name) -> props.get(@variables, name)

    update: (name, fun) -> @set(name, fun(@get(name)))

    updateState: (fun) ->
      @exState = fun(@exState)
      @exState

    pushData: (data, withState=true) ->
      if withState
        record = _.extend(@exState.toRecord(), data)
      else
        record = data

      @userData.insert(record)

    handleResponse: (arg) ->
      if arg? and arg instanceof ResponseData
        @responseQueue.push(arg)
        @pushData(arg.data)


    width: -> 0

    height: -> 0

    offsetX: -> 0

    offsetY: -> 0

    centerX: -> @width()/2 + @offsetX()

    centerY: -> @height()/2 + @offsetY()

    screenInfo: ->
      {
        width: @width()
        height: @height()
        offset:
          x: @offsetX()
          y: @offsetY()
        center:
          x: @centerX()
          y: @centerY()
      }


    logEvent: (key, value) ->

      record = _.clone(@currentTrial.record)
      record[key] = value
      @log.push(record)
      console.log(@log)

    trialData: ->
      ret = @userData().filter({ trialNumber: @exState.trialNumber })
      if ret.length == 1
        ret[0]
      else ret


    blockData: (args={blockNum: null, name: null}) ->
      if not args.blockNum?
        args.blockNum = @exState.blockNumber

      if not args.name
        @userData().filter({ blockNumber: args.blockNum })
      else
        @userData().filter({ blockNumber: args.blockNum }).select(args.name)

    allData: (args= {name: null}) ->
      if not args.name
        @userData()
      else
        @userData().select(args.name)


    showEvent: (event) -> event.start(this)

    findByID: (id) ->

    findByName: (name) ->

    showStimulus: (stimulus) ->
      p = stimulus.render(this)
      p.present(this)
      console.log("show Stimulus, drawing")
      @draw()

    start: (blockList) ->
      @numBlocks = blockList.length()

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
    p = @background.render(this)
    p.present(this, @backgroundLayer)
    #@drawBackground()

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
    #@backgroundLayer.draw()
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

  showStimulus: (stimulus) ->
    p = stimulus.render(this)
    p.present(this)
    console.log("show Stimulus, drawing")
    @draw()

  findByID: (id) ->
    if _.isArray(id)
      @stage.find("#" + i) for i in id when i?
    else
      @stage.find("#" + id)


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



buildTrial = (eventSpec, record, context, feedback, backgroundSpec) ->
  events = for key, value of eventSpec
    context.stimFactory.buildEvent(value)
  if backgroundSpec?
    background = context.stimFactory.makeStimulus("Background", backgroundSpec)
    new Trial(events, record, feedback, background)
  else
    new Trial(events, record, feedback)



makeEventSeq = (spec, context) ->
  for key, value of spec
    context.stimFactory.buildEvent(value)
    #stimSpec = _.omit(value, "Next")
    #responseSpec = _.pick(value, "Next")

    #console.log("building stim", stimSpec)

    #stim = buildStimulus(stimSpec, context)
    #response = buildResponse(responseSpec.Next, context)
    #context.stimFactory.makeEvent(stim, response, context)


buildPrelude = (preludeSpec, context) ->
  events = makeEventSeq(preludeSpec, context)
  new Prelude(events)

buildCoda = (codaSpec, context) ->
  events = makeEventSeq(codaSpec, context)
  new Coda(events)

__dummySpec =
  Events:
    1:
      Nothing: ""
      Next:
        Timeout:
          duration: 0


exports.Presenter =
class Presenter
  constructor: (@trialList, @display, @context) ->
    @trialBuilder = @display.Trial

    @prelude = if @display.Prelude?
      buildPrelude(@display.Prelude.Events, @context)
    else
      buildPrelude(__dummySpec.Events, @context)

    @coda = if @display.Coda?
      buildCoda(@display.Coda.Events, @context)
    else
      buildCoda(__dummySpec.Events, @context)

    @variables = if @display.Define?
      @context.variables = @display.Define


  start: () ->
    @blockList = new BlockSeq(for block in @trialList.blocks
      console.log("building block", block)
      trials = for trialNum in [0...block.length]
        record = _.clone(block[trialNum])
        args = {}
        args.trial = record
        args.screen = @context.screenInfo()
        trialSpec = @trialBuilder.apply(args)
        buildTrial(trialSpec.Events, record, @context, trialSpec.Feedback, trialSpec.Background)
      new Block(trials, @display.Block)
    )


    @prelude.start(@context).then(=> @blockList.start(@context)).then( => console.log("inside coda"); @coda.start(@context))





exports.letters = ['a','b','c','d','e','d','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']


#des = Design:
#  Blocks: [
#      [
#        a:1, b:2, c:3
#        a:2, b:3, c:4
#      ],
#      [
#        a:5, b:7, c:6
#        a:5, b:7, c:6
#      ]
#
#  ]

#console.log(des.Blocks)


exports.buildTrial = buildTrial
exports.buildPrelude = buildPrelude




