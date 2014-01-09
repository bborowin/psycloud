

x = [
  -> M1: a: 22
  -> M1: a: 44
]


trial = Trial:  ->
  Hello: if @y == 1 then 25 else 45


args = {y: 1 }

console.log(trial.Trial.apply(args))




