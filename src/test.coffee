

x = [
  -> M1: a: 22
  -> M1: a: 44
]


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




