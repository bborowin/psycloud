utils = require("./utils")
_ = require('lodash')
DataTable = require("./datatable").DataTable

# ## Sampler
# basic sampler that does not recycle its elements or allow sampling with replacement


## sampler as an infinite stream??

class Sampler

  constructor: (@items) ->
    @indexBuffer = _.shuffle([0...@items.length])

  next: ->
    i =
      if @indexBuffer.length > 0
        @indexBuffer.shift()
      else
        @indexBuffer = _.shuffle([0...@items.length])
        @indexBuffer.shift()

    @items[i]

  #sampleFrom: (items, n) ->
  #  for i in [0...n]
  #    next()

  takeAmong: (n, among) ->
    ret = []
    count = 0
    while count < n
      sam = takeOne()
      if _.contains(among, sam)
        ret.push(sam)
        count++

    ret


  take: (n) ->
    if n > @items.length
      throw "cannot take sample larger than the number of items when using non-replacing sampler"

    @indexBuffer = _.shuffle([0...@items.length])

    ret = for i in [0...n]
      @next()
    ret

  takeOne: ->
    @take(1)[0]

exports.Sampler = Sampler

#takeWithout: (n, exclusionSet) ->
#  pool = _.difference(@items, exclusionSet)
#  res = []
#  while (res.length != n)
#    sam = @take(1)
#    res.push(_.difference(sam, exclusionSet))
#    res = _.flatten(res)
#  _.flatten(res)

exports.ReplacementSampler =
  class ReplacementSampler extends Sampler

    sampleFrom: (items, n) ->
      utils.sample(items, n, true)

    take: (n) ->
      @sampleFrom(@items, n)



exports.BucketSampler =
  class BucketSampler extends Sampler

    constructor: (@items) ->
      @remaining = _.shuffle(@items.slice(0))

    take: (n) ->
      if n > @remaining.length
        throw new Error("cannot remove more items than are left in remaining set")
      @remaining.splice(0,n)

    size: -> @remaining.length

    putBack: (iset) ->
      if _.isArray(iset)
        ## check if iset items were in original set?
        @remaining.push(item) for item in iset
      else
        @remaining.push(iset)

      @remaining = _.shuffle(@remaining)


# ## ExhaustiveSampler
exports.ExhaustiveSampler =
  class ExhaustiveSampler extends Sampler

    @fillBuffer: (items, n) ->
      buf = (_.shuffle(items) for i in [1..n])
      _.flatten(buf)

    constructor: (@items) ->
      @buffer = ExhaustiveSampler.fillBuffer(@items, 10)

    take: (n) ->
      # the sampling strategy is **exhaustive**, which means that all items will be sampled once before any item is sampled twice.
      if n <= @buffer.length
        # if the number of requested items is less than or equal to the size of the buffer, return the next **n** items
        res = _.take(@buffer, n)
        @buffer = _.drop(@buffer, n)
        res
      else
        # otherwise, create a new buffer
        buflen = Math.max(n, 10 * @items.length)
        buf = ExhaustiveSampler.fillBuffer(@items, buflen / @items.length)
        # place remaining items from previous buffer at head of the new buffer
        ## TODO need to put remaining items at end of buffer so that they are not sampled twice in current 'take' operation
        @buffer = @buffer.concat(buf)
        @take(n)



exports.MatchSampler =
  class MatchSampler
    constructor: (@sampler) ->

    take: (n, match=true) ->
      sam = @sampler.take(n)
      if match
        probe = utils.sample(sam, 1)[0]
      else
        probe = @sampler.take(1)[0]

      probeIndex = _.indexOf(sam, probe)

      {targetSet: sam, probe: probe, probeIndex: probeIndex, match: match}




# ## UniformSampler
exports.UniformSampler =
  class UniformSampler extends Sampler

    @validate: (range) ->
      if (range.length != 2)
        throw "range must be an array with two values (min, max)"
      if (range[1] <= range[0])
        throw "range[1] must > range[0]"

    constructor: (@range) ->
      @interval = @range[1] - @range[0]

    take: (n) ->
      nums = (Math.round(Math.random() * @interval) for i in [1..n])
      nums

exports.CombinatoricSampler =
  class CombinatoricSampler extends Sampler

    constructor: (@samplers...) ->

    take: (n) ->
      for i in [0...n]
        xs = for j in [0...@samplers.length]
          @samplers[j].take(1)
        _.flatten(xs)

exports.GridSampler =
  class GridSampler extends Sampler
    constructor: (@x, @y) ->
      @grid = DataTable.expand({x:@x, y:@y})
      console.log("rows:", @grid.nrow())
      @tuples = for i in [0...@grid.nrow()]
        _.values(@grid.record(i))

    take: (n) ->
      utils.sample(@tuples, n)


# ## ConditionalSampler
exports.ConditionalSampler =
  class ConditionalSampler extends Sampler

    makeItemSubsets: () ->
      ctable = @factorSpec.conditionTable

      keySet = for i in [0...ctable.nrow()]
        record = ctable.record(i)
        levs = _.values(record)
        _.reduce(levs, ((a, b) -> a + ":" + b))

      console.log(keySet)


      itemSets = for i in [0...ctable.nrow()]
        record = ctable.record(i)
        indices = @itemMap.whichRow(record)
        @items[j] for j in indices

      console.log(itemSets)

      _.zipObject(keySet, itemSets)

    constructor: (@items, @itemMap, @factorSpec) ->
      @keyMap = @makeItemSubsets()
      @conditions = _.keys(@keyMap)
      @samplerSet = {}

      for key, value of @keyMap
        @samplerSet[key] = new ExhaustiveSampler(value)

    take: (n) ->
      keys = utils.repLen(@conditions, n)
      _.flatten(@takeCondition(keys))

    takeCondition: (keys) ->
      (@samplerSet[key].take(1) for key in keys)
