
fs = require("fs")
glob = require("glob")
csv = require('ya-csv')
Psy = require("../../build/psycloud.js")
probeTypes = ["old", "new", "similar"]
carryover = ["repeat-old", "repeat-new", "repeat-similar"]
_ = Psy._


# load images items
imageDirs = glob.sync("./images/*")
imageSets = _.map(imageDirs, (dir) -> glob.sync(dir + "/*jpg"))
imageSamplers = _.map(imageSets, (set) -> new Psy.ExhaustiveSampler(set))

# create a sampler of samplers
setSampler = {}
setSampler.sampler = new Psy.ExhaustiveSampler(imageSamplers)
setSampler.take = (n) -> this.sampler.takeOne().take(n)

## 108 new
## 108 old
## 2 runs
## 108 images per run
_ = Psy._

dt = new Psy.DataTable()

minLag = 2
maxLag = 32
pairsPerRun = 50
NRUNS = 4

generatePairs = (npairs, nfiller) ->
  lagSampler = new Psy.BucketSampler([0...(npairs*2 + nfiller)])
  lagSet = []

  while lagSet.length < npairs
    prov = lagSampler.take(2)
    dprov = Math.abs(prov[1] - prov[0])
    if dprov < minLag or dprov > maxLag
      lagSampler.putBack(prov)
    else
      lagSet.push(prov.sort((a,b) -> a-b))

  lagSet

assignConditions = (lagPairs, ntrials) ->
  slots = Psy.rep("", ntrials)
  cond = Psy.rep(["old", "similar"], [lagPairs.length/2, lagPairs.length/2])

  for i in [0...lagPairs.length]
    p = lagPairs[i]
    slots[p[0]] = "novel"
    slots[p[1]] = cond[i]

  slots = for slot in slots
    if slot is "" then "filler" else slot

  slots

generateRun = ->
  pairs = generatePairs(pairsPerRun, minLag+3)
  slots = assignConditions(pairs, pairsPerRun*2 + minLag+3)
  pairidx = Psy.rep(-1, slots.length)
  for p, index in pairs
    pairidx[p[0]] = p[1] - p[0]
    pairidx[p[1]] = p[0] - p[1]

  new Psy.DataTable({condition: slots, sibling: pairidx })


bruteMinimize = (designGenerator, minFun, niter=100) ->
  ret = for i in [0...niter]
    design = designGenerator()
    metric = minFun(design)
    { metric: metric, design: design}

  _.sortBy(ret, 'metric')

fitness = (design) ->
  transProbs = Psy.transitionProbs(design["condition"])
  toSimilar = _.filter(transProbs, (obj) -> obj.to is "similar")
  cprobs = _.map(toSimilar, (x) -> x.condProb)
  Psy.sd(cprobs)

assignItems = (design, isampler) ->
  items = Psy.rep("", design.nrow())
  for i in [0...items.length]
    record = design.record(i)
    if record.condition == "similar" and record.sibling < 0
      image = isampler.take(2)
      items[i + record.sibling] = image[0]
      items[i] = image[1]
    else if record.condition == "old" and record.sibling < 0
      image = isampler.take(1)[0]
      items[i + record.sibling] = image
      items[i] = image
    else if record.condition == "filler"
      items[i] = isampler.take(1)[0]

  items

ret = bruteMinimize(generateRun, fitness, niter=300)

fulldes = for i in [0...NRUNS]
  des = ret[i]["design"]
  console.log("binding", i)
  des.bindcol("image", assignItems(des, setSampler))
  des.bindcol("block", Psy.rep(i+1, des.nrow()))
  #console.log("run ", des)
  des

console.log("length of fulldes", fulldes.length)
des = Psy.DataTable.rbind(fulldes...)
#console.log(des)



#console.log(des1)
#console.log(des2)

#console.log(csv)
writer = csv.createCsvFileWriter("test_design.csv")
writer.writeRecord(des.colnames());
for row in des.toRecordArray()
  #console.log(row)
  writer.writeRecord(_.values(row))

writer.writeStream.end()

#console.log(writer)

#console.log(setSampler.takeOne().take(2))