_ = require('lodash')
utils = require("./utils")
DataTable = require("./datatable").DataTable
csv = require('../jslibs/jquery.csv.js')
sampler = require("./samplers")

# ## Factor
exports.Factor =
  class Factor extends Array

    @asFactor = (arr) ->
      new Factor(arr...)

    constructor: (arr) ->
      @push arg for arg in arr
      @levels = _.uniq(arr).sort()


exports.VarSpec =
  class VarSpec
    @name = ""
    @nblocks = 1
    @reps = 1
    @expanded = {}

    names: -> @name

    ntrials: ->
      @nblocks * @reps

    valueAt: (block, trial) ->



exports.FactorSpec =
  class FactorSpec extends exports.VarSpec

    constructor: (@name, @levels) ->
      @factorSet = {}
      @factorSet[@name] = @levels
      @conditionTable = DataTable.expand(@factorSet)

    cross: (other) ->
      new CrossedFactorSpec(@nblocks, @reps, [this, other])

    #levels: -> @levels

    expand: (nblocks, reps) ->
      prop = {}
      prop[@name] = @levels
      vset = new DataTable(prop)

      blocks = for i in [1..nblocks]
        vset.replicate(reps)
      concatBlocks = _.reduce(blocks, (sum, nex) -> DataTable.rbind(sum, nex))
      concatBlocks.bindcol("$Block", utils.rep([1..nblocks], utils.rep(reps * vset.nrow(), nblocks)))
      concatBlocks


exports.CellTable =
  class CellTable extends exports.VarSpec
    constructor: ( @parents) ->

      @parentNames = (fac.name for fac in @parents)
      @name = _.reduce(@parentNames, (n, n1) -> n + ":" + n1)
      @levels = (fac.levels for fac in @parents)
      @factorSet = _.zipObject(@parentNames, @levels)

      @table = DataTable.expand(@factorSet)
    #@expanded = @expand(@nblocks, @reps)

    names: -> @parentNames

    cells: -> @table.toRecordArray()

    conditions: ->
      for i in [0...@table.nrow()]
        rec = @table.record(i)
        _.reduce(rec, (n,n1) -> n + ":" + n1)


    expand: (nblocks, reps) ->
      blocks = for i in [1..nblocks]
        @table.replicate(reps)




exports.BlockStructure =
class BlockStructure

  constructor: (@nblocks, @trialsPerBlock) ->


exports.TaskNode =
  class TaskNode
    constructor: (@varNodes, @crossedSet=[]) ->
      # extract name of each variable
      @factorNames = _.map(@varNodes, (x) -> x.name)

      # store names and variables in object
      @varmap = {}
      for i in [0...@factorNames.length]
        @varmap[@factorNames[i]] = @varSpecs[i]

      if (@crossedSet.length > 0)
        @crossedVars = @varmap[vname] for vname in @crossedSet
        @crossedSpec = new CrossedFactorSpec(@crossedVars)
      else
        @crossedVars = []
        @crossedSpec = {}

      @uncrossedVars = _.difference(@factorNames, @crossedSet)
      @uncrossedSpec = @varmap[vname] for vname in @uncrossedVars

      expand: (nblocks, nreps) ->
        if @crossedVars.length > 0
          ctable = @crossedSpec.expand(nblocks, nreps)



FactorNode =
class FactorNode
  @build: (name, spec) ->
    if not spec.levels? and _.isArray(spec)
      # levels provided as value
      new FactorNode(name, spec)
    else
      # levels in 'levels' property
      new FactorNode(name, spec.levels)

  constructor: (@name, @levels) ->
    @cellTable = new CellTable([this])

  choose: -> utils.oneOf(@levels)

  chooseK: (k) -> utils.permute(@levels, k)

  chooseDependent: (recArray) -> @chooseK(recArray.length)

  expand: (nblocks, nreps) -> @cellTable.expand(nblocks, nreps)

exports.FactorNode = FactorNode

DependentFactorNode =
class DependentFactorNode
  @build: (name, spec) ->
    new DependentFactorNode(name, spec.levels, spec.choose)

  constructor: (@name, @levels, @chooseFun) ->
    @cellTable = new CellTable([this])

  choose: (record) -> @chooseFun(record)

  chooseDependent: (recArray) ->
    _.map(recArray, (rec) => @choose(rec))

  expand: (nblocks, nreps) -> @cellTable.expand(nblocks, nreps)

exports.DependentFactorNode = DependentFactorNode

## UnionDesign


exports.FactorSetNode =
  class FactorSetNode

    @build: (spec) ->

      fnodes = for key, value of spec
        exports.FactorNode.build(key, value)

      new FactorSetNode(fnodes)

    constructor: (@factors) ->
      @factorNames = _.map(@factors, (x) -> x.name)
      @varmap = {}
      for i in [0...@factorNames.length]
        @varmap[@factorNames[i]] = @factors[i]
      @cellTable = new CellTable(@factors)
      @name = @cellTable.name

    levels: -> @cellTable.levels

    conditions: -> @cellTable.conditions()

    cells: -> @cellTable.cells()

    expand: (nblocks, nreps) -> @cellTable.expand(nblocks, nreps)

    trialList: (nblocks=1, nreps=1) ->
      blocks = @expand(nblocks, nreps)
      tlist = new TrialList(nblocks)
      for blk, i in blocks
        for j in [0...blk.nrow()]
          tlist.add(i, blk.record(j))
      tlist

exports.Iterator =
  class Iterator

    hasNext: -> false
    next: -> throw "empty iterator"
    map: (fun) -> throw "empty iterator"

exports.ArrayIterator =
  class ArrayIterator extends Iterator
    constructor: (@arr) ->
      @cursor = 0

      hasNext: -> @cursor < @arr.length

      next: ->
        ret = @arr[@cursor]
        @cursor = @cursor + 1
        ret

      map: (f) -> _.map(@arr, (el) -> f(el))


class TrialList

  @fromBlockArray: (blocks) ->
    if !_.isArray(blocks)
      throw new Error("TrialList.fromBlockArray: 'blocks' argument must be an array")

    tlist = new TrialList(blocks.length)
    for i in [0...blocks.length]
      console.log("blocks[i] is", blocks[i])
      for rec in blocks[i].toRecordArray()
        tlist.add(i, rec)

    tlist

  constructor: (nblocks) ->
    @blocks = []
    @blocks.push([]) for i in [0...nblocks]

  add: (block, trial) ->
    if (block >= @blocks.length)
      blen = @blocks.length
      throw new Error("block index #{block} exceeds number of blocks in TrialList #{blen}")

    #trial.$TYPE = type
    @blocks[block].push(trial)

  get: (block, trialNum) ->
    @blocks[block][trialNum]

  getBlock: (block) ->
    @blocks[block]

  nblocks: ->
    @blocks.length

  ntrials: ->
    nt = _.map(@blocks, (b) ->
      b.length)
    _.reduce(nt, (x0, x1) ->
      x0 + x1)

  shuffle: ->
    @blocks = _.map(@blocks, (blk) ->
      _.shuffle(blk))

  bind: (fun) ->
    out = new TrialList(@blocks.length)
    for blk, i in @blocks
      for trial in blk
        ret = fun(trial)
        out.add(i, _.assign(trial, ret))
    out

  blockIterator: ->
    new ArrayIterator(_.map(@blocks, (blk) ->
      new ArrayIterator(blk)))

exports.TrialList = TrialList


trimWhiteSpace = (records) ->
  trimmed = []
  for i in [0...records.length]
    record = records[i]
    out = {}
    for key, value of record
      out[key.trim()] = value.trim()
    trimmed.push(out)
  trimmed


exports.ItemNode =
  class ItemNode

    @build: (name, spec) ->
      if not spec.type?
        spec.type = "text"

      snode = if spec.sampler?
        SamplerNode.build(spec.sampler)
      else
        new SamplerNode("default", {})

      if spec.data?
        dtable = DataTable.fromRecords(spec.data)
        attrs = dtable.dropColumn(name)
        items = dtable[name]
        new ItemNode(name, items, attrs, spec.type, snode.makeSampler(items))
      else if spec.csv?
        inode = null
        $.ajax({
          url: spec.csv.url
          dataType: "text"
          async: false
          success: (data) =>
            records = trimWhiteSpace(csv.toObjects(data))
            dtable = DataTable.fromRecords(records)
            items = dtable[name]
            attrs = dtable.dropColumn(name)
            inode = new ItemNode(name, items, attrs, spec.type, snode.makeSampler(items))
          error: (x) ->
            console.log(x)
        })



        inode

    constructor: (@name, @items, @attributes, @type, @sampler) ->
      if @items.length != @attributes.nrow()
        throw "Number of items must equal number of attributes"

    sample: (n) ->
      @sampler.take(n)

exports.ItemSetNode =
class ItemSetNode

  @build: (spec) ->
    nodes = for key, value of spec
      exports.ItemNode.build(key, value)

    new ItemSetNode(nodes)

  constructor: (@itemNodes) ->
    @names = _.map(@itemNodes, (n) -> n.name)

  sample: (n) ->
    items = _.map(@itemNodes, (node) -> node.sample(n) )
    out = []
    for i in [0...n]
      record = {}
      for name, j in @names
        record[name] = items[j][i]
      out.push(record)

    out




SamplerNode =
class SamplerNode

  @build: (spec) ->
    if not spec.type?
      spec.type = "default"
    new SamplerNode(spec.type, spec)

  constructor: (type, params) ->
    @makeSampler = switch type
      when "default"
        (items) -> new sampler.Sampler(items, params)
      when "exhaustive"
        (items) -> new sampler.ExhaustiveSampler(items, params)
      when "replacement"
        (items) -> new sampler.ReplacementSampler(items, params)
      else
        throw new Error("unrecognized sampler type", type)

exports.SamplerNode = SamplerNode

exports.ConditionSet =
class ConditionSet

  @build: (spec) ->
    if not spec.Crossed? and not spec.Uncrossed
      ## assume crossed
      _crossed = exports.FactorSetNode.build(spec.Crossed)
      _uncrossed = {}
    else
      _crossed = exports.FactorSetNode.build(spec.Crossed)
      _uncrossed = for key, value of spec.Uncrossed
        DependentFactorNode.build(key, value)

    new ConditionSet(_crossed, _uncrossed)

  constructor: (@crossed, @uncrossed) ->
    @factorNames = [].concat(@crossed.factorNames).concat(_.map(@uncrossed, (fac) => fac.name))

    @factorArray = _.clone(@crossed.factors)

    _.forEach(@uncrossed, (fac) => @factorArray.push(fac))

    @factorSet = _.zipObject(@factorNames, @factorArray)

  expand: (nblocks, nreps) ->
    cellTab = @crossed.expand(nblocks, nreps)
    for blk in cellTab
      for i in [0...@uncrossed.length]
        blk.bindcol(@uncrossed[i].name, @uncrossed[i].chooseDependent(blk.toRecordArray()))

    TrialList.fromBlockArray(cellTab)





#exports.Task =
#class Task

#  @build: (spec) ->

#  constructor: (@name, @yy) ->


# ## ExpDesign
# A class that represents an experimental design consisting of an array of one or more **blocks**
# each consisting of a set of one or more **trials**.
exports.ExpDesign =
  class ExpDesign

    @blocks = 1


    #blockTrials: (blocknum) ->
    #  @design[blocknum]

    #ncells: (includeBlock=false) ->
    #  if (includeBlock)
    #    @crossedCells.nrow() * @blocks
    #  else
    #    @crossedCells.nrow()


    #ntrials: (byBlock=false) ->
    #  blen = _.map(@design, (x) -> x.nrow())
    #  if (byBlock)
    #    blen
    #  else
    #    _.reduce(blen, (sum, num) -> sum + num)

    #crossVariables: (vars) -> DataTable.expand(vars)

    @validate: (spec) ->
      if (!("Design" of spec))
        throw "Design is undefined"
      des = spec["Design"]

      if (!("Variables" of des))
        throw "Variables is undefined"
      if (!("Structure" of des))
        throw "Structure is undefined"
      if (!("Items" of spec))
        throw "Items is undefined"

    @splitCrossedItems: (itemSpec, crossedVariables) ->
      ## TODO must check that item section contains these variables
      attrnames = crossedVariables.colnames()


      keySet = for i in [0...crossedVariables.nrow()]
        record = crossedVariables.record(i)
        levs = _.values(record)
        _.reduce(levs, ((a, b) -> a + ":" + b))


      values = itemSpec["values"]

      conditionTable = new DataTable(_.pick(itemSpec, attrnames))

      itemSets = for i in [0...crossedVariables.nrow()]
        record = crossedVariables.record(i)
        indices = conditionTable.whichRow(record)
        values[j] for j in indices


      _.zipObject(keySet, itemSets)



    init: (spec) ->
      @design = spec["Design"]

      @variables = @design["Variables"]

      @itemSpec = spec["Items"]

      @structure = @design["Structure"]

      @factorNames = _.keys(@variables)

      @crossed = @variables["Crossed"]

      @auxiliary = @variables["Auxiliary"]

    initStructure: ->
      if (@structure["type"] == "Block")
        if (!_.has(@structure, "reps_per_block"))
          @structure["reps_per_block"] = 1

        @reps_per_block = @structure["reps_per_block"]

        @blocks = @structure["blocks"]
      else
        @reps_per_block = 1
        @blocks = 1


    makeConditionalSampler: (crossedSpec, crossedItems) ->
      crossedItemName = _.keys(crossedItems)[0]
      console.log("names:", crossedSpec.names())
      crossedItemMap = (crossedItems[crossedItemName][key] for key in crossedSpec.names())
      crossedItemMap = _.zipObject(_.keys(@crossed), crossedItemMap)
      console.log("item map: ", crossedItemMap)
      new ConditionalSampler(crossedItems[crossedItemName].values, new DataTable(crossedItemMap), crossedSpec)

    makeCrossedSpec: (crossed, nblocks, nreps) ->
      factors = for key, val of crossed
        new FactorSpec(nblocks, nreps, key, val.levels)

      crossed = new CrossedFactorSpec(nblocks, nreps, factors)

    makeFactorSpec: (fac, nblocks, nreps) ->
      new FactorSpec(nblocks, nreps, _.keys(fac)[0], _.values(fac)[0])


    constructor: (spec = {}) ->
      ## validate format of spec structure
      ExpDesign.validate(spec)
      @init(spec)
      @initStructure()

      @crossedSpec = @makeCrossedSpec(@crossed, @blocks, @reps_per_block)
      crossedItems = @itemSpec.Crossed

      crossedSampler = @makeConditionalSampler(@crossedSpec, crossedItems)

      @fullDesign = @crossedSpec.expanded.bindcol(_.keys(crossedItems)[0], crossedSampler.take(@crossedSpec.expanded.nrow()))

      console.log(@crossedDesign)

