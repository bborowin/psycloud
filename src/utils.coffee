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
  if not (vec instanceof Array)
    vec = [vec]

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

exports.genPoints = (n, bbox={X: 0, y: 0, width: 1, height: 1}) ->
  out = []
  for i in [0...n]
    x = Math.random() * bbox.width + bbox.x
    y = Math.random() * bbox.height + bbox.y
    out.push([x,y])
  out

exports.euclidean = (a, b) ->
  sum = 0
  for n in [0...a.length]
    sum = sum + Math.pow(a[n]-b[n], 2)

  return Math.sqrt(sum)

exports.order = (els) ->
  toSort = els.slice(0)

  for i in [0...toSort.length]
    toSort[i] = [toSort[i], i]

  toSort.sort (left, right) ->
    (if left[0] < right[0] then -1 else 1)

  sortIndices = []

  for j in [0...toSort.length]
    sortIndices.push toSort[j][1]

  sortIndices


exports.table = (els) ->
  counts = _.reduce(els,
  (sum, x) ->
    if sum[x]?
      sum[x] = sum[x] + 1
    else
      sum[x] = 1
    sum
  {})

  counts


exports.transitionProbs = (els) ->
  zipped =  _.zip(_.initial(els), _.rest(els))
  zipped = _.map(zipped, (x) -> {from: x[0], to: x[1]})
  counts = _.reduce(zipped,
    (sum, x) ->
      key = JSON.stringify(x)
      if sum[key]?
        sum[key] = sum[key] + 1
      else
        sum[key] = 1
      sum
    {})


  classCounts = exports.table(els)

  counts = for key, value of counts
    trans = JSON.parse(key)
    {from: trans.from, to: trans.to, count: value, prob: value/zipped.length, condProb: value/classCounts[trans.from]}


  counts



exports.sd = (els) ->
  sum = 0
  for el in els
    sum = sum + el
  mu = sum/els.length
  ss = 0
  for el in els
    ss  = ss + Math.pow(el - mu,2)

  Math.sqrt(ss/els.length)






exports.distanceMatrix = (pts) ->
  for i in [0...pts.length]
    for j in [0...pts.length]
      exports.euclidean(pts[i], pts[j])


exports.which = (vals, fun) ->
  out = []
  for v in vals
    out.push(v) if fun(v)

  v

exports.whichMin = (vals) ->
  min = vals[0]
  imin = 0
  for i in [0...vals.length]
    if vals[i] < min
      min = vals[i]
      imin = i

  imin

exports.nearestTo = (pt, pointSet, k) ->
  D = for i in [0...pointSet.length]
    exports.euclidean(pt, pointSet[i])

  Dord = exports.order(D)

  for i in [0...k]
    {index: Dord[i], distance: D[Dord[i]]}

exports.nearestNeighbors = (pointSet, k) ->
  D = exports.distanceMatrix(pointSet)

  dlin = []
  ind = []
  for i in [0...D.length]
    for j in [0...D.length] when i != j and i < j
      dlin.push(D[i][j])
      ind.push([i,j])

  dord = exports.order(dlin)

  out = []
  for i in [0...k]
    out.push({ index: ind[dord[i]], distance: dlin[dord[i]] })
  out




exports.pathLength = (pts) ->
  if pts.length <= 1
    0
  else
    len = 0
    for i in [0...(pts.length-1)]
      len += exports.euclidean(pts[i], pts[i+1])
    len


exports.nearestFromIndex = (pts, index) ->
  D = for i in [0...pts.length]  when i != index
    exports.euclidean(pts[index], pts[i])

  imin = exports.whichMin(D)

  if imin < index
    imin
  else
    imin + 1



console.log(exports.distanceMatrix([ [0,1], [1,2], [2,2]]))
console.log(exports.nearestFromIndex([ [0,1], [1,2], [2,2], [0,1.2]], 1))

console.log(exports.nearestTo([0,1], [ [0,1], [1,2], [2,2], [0,1.2]], 2))
console.log(exports.nearestNeighbors([ [0,1], [1,2], [2,2], [0,1.2], [0,1.001]], 2))

console.log(exports.pathLength([ [0,1], [0,2], [0,3], [0,4], [0,5]]))


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



