




x = [
  -> M1: a: 22
  -> M1: a: 44
]

{match} = require("coffee-pattern")
_ = require("lodash")
utils = require("./utils")



trial = Trial:  ->
  Hello: if @y == 1 then 25 else 45


args = {y: 1 }

console.log(trial.Trial.apply(args))




drawable =
  (knode) -> (context) -> console.log("hello?", knode, "context", context)

f = drawable("mycontext")
f("arrow")

class X

  constructor: (@z) ->

  x: -> console.log("X", @z)

Y = new (class extends X
)("hh")

Y.x()




ret = match 103,
  utils.inSet(7,8), "hello",
  utils.inSet(103), "goodbye",


console.log(ret)

x = utils.permute([ 2, 1, 3, 4, 5, 6 ], 12)
console.log(x)

#console.log(utils.permute([1,2,3]))


