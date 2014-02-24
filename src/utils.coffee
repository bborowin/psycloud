_ = require('lodash')

#$ = window?.jQuery or window?.Zepto or (element) -> element


if window?.performance?.now
  getTimestamp = -> window.performance.now()
else if window?.performance?.webkitNow
  getTimestamp = -> window.performance.webkitNow()
else
  getTimestamp = -> new Date().getTime()

exports.getTimestamp = getTimestamp

@browserBackDisabled = false

exports.disableBrowserBack = ->
  if not @browserBackDisabled
    rx = /INPUT|SELECT|TEXTAREA/i

    @browserBackDisabled = true

    $(document).bind("keydown keypress", (e) ->
      if e.which is 8
        if !rx.test(e.target.tagName) or e.target.disabled or e.target.readOnly
          e.preventDefault())


exports.module = (name) ->
  global[name] = global[name] or {}

exports.asArray = (value) ->
  if (_.isArray(value))
    value
  else if (_.isNumber(value) or _.isBoolean(value))
    [value]
  else
    _.toArray(value)


swap = (arr, a, b) ->
  temp = arr[a]
  arr[a] = arr[b]
  arr[b] = temp

factorial = (n) ->
  val = 1
  i = 1

  while i < n
    val *= i
    i++
  val

exports.permute = (perm, maxlen=1000) ->
  console.log("maxlen", maxlen)
  total = factorial(perm.length)
  console.log("total", total)
  j = 0
  i = 0
  inc = 1

  out = []

  maxlen = maxlen - 1

  while j < total and out.length < maxlen
    console.log("j", j)
    while i < perm.length - 1 and i >= 0 and out.length < maxlen
      out.push(perm.slice(0))
      swap perm, i, i + 1
      i += inc
    out.push(perm.slice(0))
    if inc is 1
      swap perm, 0, 1
    else
      swap perm, perm.length - 1, perm.length - 2
    j++
    inc *= -1
    i += inc
  out

###
exports.permute = (input) ->
  input = _.unique(input)
  permArr = []
  usedChars = []

  maxlen = _.min([input.length, maxlen])

  exports.main = main = (input) ->

    for i in [0...input.length]
      ch = input.splice(i, 1)[0]
      usedChars.push(ch)
      if (input.length == 0)
        permArr.push(usedChars.slice())

      main(input)
      input.splice(i, 0, ch)
      usedChars.pop()

    permArr

  main(input)
###

exports.rep = (vec, times) ->
  if not (times instanceof Array)
    times = [times]

  if (times.length != 1 and vec.length != times.length)
    throw "vec.length must equal times.length or times.length must be 1"
  if vec.length == times.length
    out = for el, i in vec
      for j in [1..times[i]]
        el
    _.flatten(out)
  else
    out = _.times(times[0], (n) => vec)
    _.flatten(out)

exports.repLen = (vec, length) ->
  if (length < 1)
    throw "repLen: length must be greater than or equal to 1"

  for i in [0...length]
    vec[i % vec.length]


exports.sample = (elements, n, replace=false) ->
  if n > elements.length and not replace
    throw "cannot take sample larger than the number of elements when 'replace' argument is false"
  if not replace
    _.shuffle(elements)[0...n]
  else
    for i in [0...n]
      elements[Math.floor(Math.random() * elements.length)]

exports.oneOf = (elements) -> elements[Math.floor(Math.random() * elements.length)]

#exports.in = (x, set) -> _.contains(x,set)

exports.inSet = (set...) ->
  set = _.unique(_.flatten(set))
  (a) ->
    _.contains(set, a)

exports.doTimer = (length, oncomplete) ->
  start = getTimestamp()
  instance = ->
    diff = (getTimestamp() - start)
    if diff >= length
      oncomplete(diff)
    else
      half = Math.max((length - diff)/2,1)
      if half < 20
        half = 1
      setTimeout instance, half

  setTimeout instance, 1



