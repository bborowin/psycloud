// Generated by CoffeeScript 1.7.1
(function() {
  var match, _;

  _ = Psy._;

  match = Psy.match;

  module("DataTable");

  test('can create a DataTable from a single record, and it has one row', function() {
    var dt, record;
    record = {
      a: 1,
      b: 2,
      c: 3
    };
    dt = new Psy.DataTable.fromRecords([record]);
    return equal(dt.nrow(), 1);
  });

  test('can create a DataTable from a two records, and it has two rows', function() {
    var dt, records;
    records = [
      {
        a: 1,
        b: 2,
        c: 3
      }, {
        a: 1,
        b: 2,
        c: 3
      }
    ];
    dt = new Psy.DataTable.fromRecords(records);
    return equal(dt.nrow(), 2);
  });

  test('can create a DataTable from a two records, with partially overlapping keys', function() {
    var dt, records;
    records = [
      {
        a: 1,
        b: 2,
        c: 3
      }, {
        b: 2,
        c: 3,
        x: 7
      }
    ];
    dt = new Psy.DataTable.fromRecords(records);
    equal(dt.ncol(), 4);
    return equal(dt.nrow(), 2);
  });

  test('can concatenate two DataTables with different column names with rbind, union=true', function() {
    var dt1, dt2, dt3;
    dt1 = new Psy.DataTable({
      a: [1, 2, 3],
      b: [5, 6, 7]
    });
    dt2 = new Psy.DataTable({
      a: [1, 2, 3],
      d: [5, 6, 7]
    });
    dt3 = Psy.DataTable.rbind(dt1, dt2, true);
    equal(3, dt3.ncol());
    return equal(6, dt3.nrow());
  });

  test('can drop a column from a DataTable', function() {
    var dt1, dt2;
    dt1 = new Psy.DataTable({
      a: [1, 2, 3],
      b: [5, 6, 7]
    });
    dt2 = dt1.dropColumn("a");
    return equal(dt2.ncol(), 1);
  });

  test('can shuffle a DataTable', function() {
    var dt1, dt2;
    dt1 = new Psy.DataTable({
      a: [1, 2, 3],
      b: [5, 6, 7]
    });
    dt2 = dt1.shuffle();
    return equal(dt1.nrow(), dt2.nrow());
  });

  test('DataTable replicate 1 yields cloned copy', function() {
    var dt1, dt2;
    dt1 = new Psy.DataTable({
      a: [1, 2, 3],
      b: [5, 6, 7]
    });
    dt2 = dt1.replicate(1);
    return deepEqual(dt1, dt2);
  });

  test('Can create an empty DataTable and add rows', function() {
    var dt;
    dt = new Psy.DataTable();
    dt.bindrow({
      x: 1,
      y: 2
    });
    dt.bindrow({
      x: 2,
      y: 3
    });
    return console.log("data table", dt);
  });

  module("Sampler");

  test('Can sample from a basic non-replacing sampler', function() {
    var sampler;
    sampler = new Psy.Sampler([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    return ok(true, sampler.next());
  });

  test('Can sample repeatedly from a basic non-replacing sampler', function() {
    var i, out, sampler, _i;
    sampler = new Psy.Sampler([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    out = "";
    for (i = _i = 0; _i <= 30; i = ++_i) {
      out = out + sampler.next() + " ";
    }
    return ok(true, out);
  });

  test('Can take N elements from a non-replacing sampler', function() {
    var out, sampler;
    sampler = new Psy.Sampler([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    out = sampler.take(8);
    out = out.concat(sampler.take(8));
    equal(out.length, 16);
    return ok(true, out);
  });

  module("FactorNode");

  test('Can create a FactorNode from an object literal', function() {
    var fac, fnode;
    fnode = {
      fac: {
        levels: [1, 2, 3, 4, 5]
      }
    };
    fac = new Psy.FactorNode.build("fac", fnode.fac);
    equal(fac.name, "fac");
    return equal(fac.levels.toString(), [1, 2, 3, 4, 5].toString(), fac.levels);
  });

  module("FactorSetNode");

  test('can create a FactorSetNode from an object literal', function() {
    var fnode, fset;
    fset = {
      FactorSet: {
        wordtype: {
          levels: ["word", "pseudo"]
        },
        repnum: {
          levels: [1, 2, 3, 4, 5, 6]
        },
        lag: {
          levels: [1, 2, 4, 8, 16, 32]
        }
      }
    };
    fnode = Psy.FactorSetNode.build(fset["FactorSet"]);
    equal(fnode.factorNames.toString(), ["wordtype", "repnum", "lag"].toString(), fnode.factorNames.toString());
    return equal(fnode.varmap["wordtype"].levels.toString(), ["word", "pseudo"].toString(), fnode.varmap["wordtype"].levels.toString());
  });

  module("ConditionSet");

  test('can build a ConditionSet from object literal', function() {
    var cset, xs;
    cset = {
      Crossed: {
        wordtype: {
          levels: ["word", "pseudo"]
        },
        repnum: {
          levels: [1, 2, 3, 4, 5, 6]
        },
        lag: {
          levels: [1, 2, 4, 8, 16, 32]
        }
      },
      Uncrossed: {
        novel: {
          levels: ["a", "b", "c"]
        },
        color: {
          levels: ["red", "green", "blue"]
        }
      }
    };
    xs = Psy.ConditionSet.build(cset);
    deepEqual(["wordtype", "repnum", "lag", "novel", "color"], xs.factorNames);
    return deepEqual(["wordtype", "repnum", "lag", "novel", "color"], _.keys(xs.factorSet));
  });

  test('can build a ConditionSet from object literal with choose function', function() {
    var cset, ex, xs;
    cset = {
      Crossed: {
        wordtype: {
          levels: ["word", "pseudo"]
        },
        repnum: {
          levels: [1, 2, 3, 4, 5, 6]
        },
        lag: {
          levels: [1, 2, 4, 8, 16, 32]
        }
      },
      Uncrossed: {
        novel: {
          levels: ["a", "b", "c"],
          choose: function(trial) {
            return match(trial.lag, Psy.inSet(1, 2), "a", Psy.inSet(4, 8), "b", Psy.inSet(16, 32), "c");
          }
        },
        color: {
          levels: ["red", "green", "blue"],
          choose: function(trial) {
            return "red";
          }
        }
      }
    };
    xs = Psy.ConditionSet.build(cset);
    ex = xs.expand(5, 5);
    console.log("expanded", ex);
    return expect(0);
  });

  module("Task");

  test('can build a task with one set of crossed variables', function() {
    var task;
    task = {
      Task: {
        name: "task1",
        Conditions: {
          Crossed: {
            wordtype: {
              levels: ["word", "pseudo"]
            },
            repnum: {
              levels: [1, 2, 3, 4, 5, 6]
            },
            lag: {
              levels: [1, 2, 4, 8, 16, 32]
            }
          }
        },
        Items: {
          word: {
            data: [
              {
                word: "hello",
                x: 1,
                y: 4
              }, {
                word: "goodbye",
                x: 2,
                y: 5
              }, {
                word: "yahoo",
                x: 3,
                y: 6
              }
            ],
            sampler: {
              type: "replacement"
            }
          },
          color: {
            data: [
              {
                color: "red",
                x: 10
              }, {
                color: "green",
                x: 20
              }, {
                color: "blue",
                x: 30
              }
            ],
            sampler: {
              type: "replacement"
            }
          }
        }
      }
    };
    return expect(0);
  });

  module("TrialList");

  test('can build a TrialList', function() {
    var tlist;
    tlist = new Psy.TrialList(6);
    tlist.add(0, {
      wordtype: "word",
      lag: 1,
      repnum: 1
    });
    tlist.add(0, {
      wordtype: "pseudo",
      lag: 2,
      repnum: 2
    });
    tlist.add(0, {
      wordtype: "word",
      lag: 4,
      repnum: 3
    });
    tlist.add(1, {
      wordtype: "word",
      lag: 2,
      repnum: 3
    });
    tlist.add(5, {
      wordtype: "word",
      lag: 2,
      repnum: 3
    });
    return equal(tlist.ntrials(), 5);
  });

  test('can bind a new variable to a TrialList', function() {
    var blk, i, tlist, trial, _i, _ref, _results;
    tlist = new Psy.TrialList(6);
    tlist.add(0, {
      wordtype: "word",
      lag: 1,
      repnum: 1
    });
    tlist.add(0, {
      wordtype: "pseudo",
      lag: 2,
      repnum: 2
    });
    tlist.add(0, {
      wordtype: "word",
      lag: 4,
      repnum: 3
    });
    tlist.add(1, {
      wordtype: "word",
      lag: 2,
      repnum: 3
    });
    tlist.add(5, {
      wordtype: "word",
      lag: 2,
      repnum: 3
    });
    tlist = tlist.bind(function(record) {
      return {
        number: 1
      };
    });
    equal(tlist.nblocks(), 6);
    _results = [];
    for (i = _i = 0, _ref = tlist.nblocks(); 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      blk = tlist.getBlock(i);
      _results.push((function() {
        var _j, _len, _results1;
        _results1 = [];
        for (_j = 0, _len = blk.length; _j < _len; _j++) {
          trial = blk[_j];
          _results1.push(equal(trial.number, 1));
        }
        return _results1;
      })());
    }
    return _results;
  });

  module("ItemNode");

  test('can build an ItemNode from object literal', function() {
    var inode, node;
    inode = {
      data: [
        {
          item: "a",
          x: 1,
          y: 4
        }, {
          item: "b",
          x: 2,
          y: 5
        }, {
          item: "c",
          x: 3,
          y: 6
        }
      ],
      type: "text"
    };
    node = Psy.ItemNode.build("item", inode);
    equal(node.name, "item");
    equal(node.attributes.x.toString(), [1, 2, 3].toString(), node.attributes.x.toString());
    return equal(node.attributes.y.toString(), [4, 5, 6].toString(), node.attributes.x.toString());
  });

  module("ItemNode");

  test('can build an ItemNode from a csv file', function() {
    var inode, items, node;
    inode = {
      csv: {
        url: '../data/test.csv'
      },
      type: "text"
    };
    node = Psy.ItemNode.build("num", inode);
    equal(node.name, "num");
    items = node.sample(2);
    equal(items.length, 2);
    return deepEqual(node.attributes.color, ["red", "green"], node.attributes.color.toString());
  });

  module("ItemSetNode");

  test('can build an ItemSetNode from a set of object literals', function() {
    var iset, nodes;
    nodes = {
      word: {
        data: [
          {
            word: "hello",
            x: 1,
            y: 4
          }, {
            word: "goodbye",
            x: 2,
            y: 5
          }, {
            word: "yahoo",
            x: 3,
            y: 6
          }
        ],
        sampler: {
          type: "replacement"
        }
      },
      color: {
        data: [
          {
            color: "red",
            x: 10
          }, {
            color: "green",
            x: 20
          }, {
            color: "blue",
            x: 30
          }
        ],
        sampler: {
          type: "replacement"
        }
      }
    };
    iset = Psy.ItemSetNode.build(nodes);
    console.log("item set sample 50", Psy.DataTable.fromRecords(iset.sample(50)));
    return deepEqual(["word", "color"], iset.names);
  });

  module("AbsoluteLayout");

  test('AbsoluteLayout correcty converts percentage to fraction', function() {
    var layout, xy;
    layout = new Psy.AbsoluteLayout();
    xy = layout.computePosition([1000, 1000], ["10%", "90%"]);
    equal(xy[0], 1000 * 0.10, "10% of 1000 is " + xy[0]);
    return equal(xy[1], 1000 * 0.90, "90% of 1000 is " + xy[1]);
  });

  test('AbsoluteLayout handles raw pixels', function() {
    var layout, xy;
    layout = new Psy.AbsoluteLayout();
    xy = layout.computePosition([1000, 1000], [10, 90]);
    equal(xy[0], 10);
    return equal(xy[1], 90);
  });

  module("Prelude");

  test('Can create a Prelude Block froma spec', function() {
    var block, context, events, key, prelude, value;
    prelude = {
      Prelude: {
        Events: {
          Instructions: {
            pages: {
              1: {
                MarkDown: "Welcome to the Experiment!\n=========================="
              },
              2: {
                Markdown: "Awesome!!!\n========================="
              }
            }
          }
        }
      }
    };
    context = new Psy.ExperimentContext(new Psy.MockStimFactory());
    events = (function() {
      var _ref, _results;
      _ref = prelude.Prelude.Events;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        _results.push(Psy.buildEvent(value, context));
      }
      return _results;
    })();
    block = new Psy.Block(events);
    ok(block);
    return equal(block.length(), 1, block.length());
  });

  module("Instructions");

  test('Can create an Instructions element', function() {
    var componentFactory, instructions, prelude;
    prelude = {
      Prelude: {
        Instructions: {
          pages: {
            1: {
              MarkDown: "Welcome to the Experiment!\n=========================="
            },
            2: {
              Markdown: "Awesome!!!\n========================="
            }
          }
        }
      }
    };
    componentFactory = new Psy.DefaultComponentFactory();
    instructions = componentFactory.makeStimulus("Instructions", prelude.Prelude.Instructions);
    return equal(instructions.pages.length, 2);
  });

  module("csv");

  asyncTest('can read a csv file using ajax', 1, function() {
    console.log("Psy.csv?", Psy.csv);
    return $.ajax({
      url: '../data/test.csv',
      dataType: "text",
      success: function(data) {
        ok(true, "successfully fetched csv file", Psy.csv.toObjects(data));
        return start();
      },
      error: function(x) {
        return console.log(x);
      }
    });
  });

  module("rep");

  test('Psy.rep works with a single value and single times argument', function() {
    var x;
    x = Psy.rep("", 3);
    return deepEqual(x, ["", "", ""]);
  });

}).call(this);
