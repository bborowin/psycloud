_ = Psy._


module("DataTable")
test 'can create a DataTable from a single record, and it has one row', ->
  record = {a:1, b: 2, c: 3}
  dt =new Psy.DataTable.fromRecords([record])
  equal(dt.nrow(), 1)

test 'can create a DataTable from a two records, and it has two rows', ->
  records = [{a:1, b: 2, c: 3},{a:1, b: 2, c: 3}]
  dt =new Psy.DataTable.fromRecords(records)
  equal(dt.nrow(), 2)

test 'can create a DataTable from a two records, with partially overlapping keys', ->
  records = [{a:1, b: 2, c: 3},{b: 2, c: 3, x:7}]
  dt = new Psy.DataTable.fromRecords(records)
  equal(dt.ncol(), 4)
  equal(dt.nrow(), 2)

test 'can concatenate two DataTables with different column names with rbind, union=true', ->
  dt1 = new Psy.DataTable({a: [1,2,3], b:[5,6,7]})
  dt2 = new Psy.DataTable({a: [1,2,3], d:[5,6,7]})

  dt3 = Psy.DataTable.rbind(dt1,dt2,true)
  equal(3, dt3.ncol())
  equal(6, dt3.nrow())


module("FactorNode")
test 'Can create a FactorNode from an object literal', ->
  fnode =
    fac:
      levels: [1,2,3,4,5]
  fac = new Psy.FactorNode.build("fac", fnode.fac)

  equal(fac.name, "fac")
  equal(fac.levels.toString(), [1,2,3,4,5].toString(), fac.levels)

module("FactorSetNode")
test 'can create a FactorSetNode from an object literal', ->
  fset =
    FactorSet:
      wordtype:
        levels: ["word", "pseudo"]
      repnum:
        levels: [1,2,3,4,5,6]
      lag:
        levels: [1,2,4,8,16,32]

  fnode = Psy.FactorSetNode.build(fset["FactorSet"])
  equal(fnode.factorNames.toString(), ["wordtype", "repnum", "lag"].toString(), fnode.factorNames.toString())
  equal(fnode.varmap["wordtype"].levels.toString(), ["word", "pseudo"].toString(), fnode.varmap["wordtype"].levels.toString())
  #equal(fnode.cellTable.table.nrow(), 2*6*6)



module("ConditionSet")
test 'can build a ConditionSet from object literal', ->
  cset =
    Crossed:
      wordtype:
        levels: ["word", "pseudo"]
      repnum:
        levels: [1,2,3,4,5,6]
      lag:
        levels: [1,2,4,8,16,32]
    Uncrossed:
      novel:
        levels: ["a", "b", "c"]
      color:
        levels: ["red", "green", "blue"]

  xs = Psy.ConditionSet.build(cset)
  console.log("xs", xs)
  deepEqual(["wordtype", "repnum", "lag", "novel", "color"], xs.factorNames)
  deepEqual(["wordtype", "repnum", "lag", "novel", "color"], _.keys(xs.factorSet))

module("TrialList")
test 'can build a TrialList', ->
  tlist = new Psy.TrialList(6)
  tlist.add(0,{wordtype: "word", lag: 1, repnum: 1})
  tlist.add(0,{wordtype: "pseudo", lag: 2, repnum: 2})
  tlist.add(0,{wordtype: "word", lag: 4, repnum: 3})
  tlist.add(1,{wordtype: "word", lag: 2, repnum: 3})
  tlist.add(5,{wordtype: "word", lag: 2, repnum: 3})

  equal(tlist.ntrials(), 5)

test 'can bind a new variable to a TrialList', ->
  tlist = new Psy.TrialList(6)
  tlist.add(0,{wordtype: "word", lag: 1, repnum: 1})
  tlist.add(0,{wordtype: "pseudo", lag: 2, repnum: 2})
  tlist.add(0,{wordtype: "word", lag: 4, repnum: 3})
  tlist.add(1,{wordtype: "word", lag: 2, repnum: 3})
  tlist.add(5,{wordtype: "word", lag: 2, repnum: 3})

  tlist = tlist.bind( (record) ->
    number: 1
  )

  equal(tlist.nblocks(), 6)

  for i in [0...tlist.nblocks()]
    blk = tlist.getBlock(i)
    for trial in blk
      equal(trial.number, 1)


module("ItemNode")
test 'can build an ItemNode from object literal', ->
  inode =
    items: ["a", "b", "c"]
    attributes:
      x: [1,2,3]
      y: [4,5,6]
    type: "text"

  node = Psy.ItemNode.build("inode", inode)
  equal(node.name, "inode")
  equal(node.attributes.x.toString(), [1,2,3].toString(), node.attributes.x.toString())
  equal(node.attributes.y.toString(), [4,5,6].toString(), node.attributes.x.toString())



module("AbsoluteLayout")

test 'AbsoluteLayout correcty converts percentage to fraction', ->
  layout = new Psy.AbsoluteLayout()
  xy = layout.computePosition([1000,1000], ["10%", "90%"])
  equal(xy[0], 1000 * 0.10, "10% of 1000 is " + xy[0])
  equal(xy[1], 1000 * 0.90, "90% of 1000 is " + xy[1])

test 'AbsoluteLayout handles raw pixels', ->
  layout = new Psy.AbsoluteLayout()


  xy = layout.computePosition([1000, 1000], [10, 90])
  equal(xy[0], 10)
  equal(xy[1], 90)


module("Prelude")
test 'Can create a Prelude Block froma spec', ->
  prelude = Prelude:
    Events:
      Instructions:
        pages:
          1:
            MarkDown: """
              Welcome to the Experiment!
              ==========================
            """
          2:
            Markdown: """
              Awesome!!!
              =========================
            """
  context = new Psy.ExperimentContext(new Psy.MockStimFactory())
  events = for key, value of prelude.Prelude.Events
      console.log("key", key)
      console.log("value", value)
      ev = Psy.buildEvent(value, context)
      console.log("event", ev)
      ev
  block = new Psy.Block(events)
  console.log("block", block)
  ok(block)
  equal(block.length(), 1, block.length())



module("Instructions")
test 'Can create an Instructions element', ->
  prelude = Prelude:
    Instructions:
      pages:
        1:
          MarkDown: """
            Welcome to the Experiment!
            ==========================
          """
        2:
          Markdown: """
            Awesome!!!
            =========================
          """

  #instructions = new Psy.Instructions(prelude.Prelude.Instructions)
  componentFactory = new Psy.DefaultComponentFactory()
  instructions = componentFactory.makeStimulus("Instructions", prelude.Prelude.Instructions)
  equal(instructions.pages.length, 2)





