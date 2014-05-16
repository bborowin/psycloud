_ = require('lodash')


isPercentage = (perc) -> _.isString(perc) and perc.slice(-1) is "%"


isPositionLabel = (pos) ->
  _.contains(["center", "center-left", "center-right","top-left", "top-right", "top-center", "bottom-left", "bottom-right", "bottom-center",
              "left-center", "right-center","left-top", "right-top", "center-top", "left-bottom", "right-bottom", "center-bottom"], pos)

positionToCoord = (pos, offx, offy, width, height, xy) ->
  switch pos
    when "center" then [offx + width * .5, offy + height * .5]
    when "center-left" or "left-center" then [offx + width/6, offy + height * .5]
    when "center-right" or "right-center" then [offx + width * 5/6, offy + height * .5]
    when "top-left" or "left-top" then [offx + width/6, offy + height/6]
    when "top-right" or "right-top" then [offx + width * 5/6, offy + height/6]
    when "top-center" or "center-top" then [offx + width * .5, offy + height/6]
    when "bottom-left" or "left-bottom" then [offx + width/6, offy + height * 5/6]
    when "bottom-right" or "right-bottom" then [offx + width * 5/6, offy + height * 5/6]
    when "bottom-center" or "center-bottom" then [offx + width * .5, offy + height * 5/6]
    else xy


toPixels = (arg, dim) ->
  if _.isNumber(arg)
    arg
  else if isPercentage(arg)
    convertPercentageToFraction(arg, dim)
  else
    throw new Error("toPixels: argument must either be a Number or a String-based Percentage value: ", arg)


convertPercentageToFraction = (perc, dim) ->
  frac = parseFloat(perc)/100
  frac = Math.min(1,frac)
  frac = Math.max(0,frac)
  frac * dim

convertToCoordinate = (val, d) ->
  if isPercentage val
    val = convertPercentageToFraction(val, d)
  else if isPositionLabel val
    ret = positionToCoord(val, 0, 0, d[0], d[1], [0,0])
    #console.log("position coordinate", ret)
    ret
  else
    Math.min(val, d)

computeGridCells = (rows, cols, bounds) ->
  for row in [0...rows]
    for col in [0...cols]
      {
      x: bounds.x + bounds.width/cols * col
      y: bounds.y + bounds.height/rows * row
      width:  bounds.width/cols
      height: bounds.height/rows
      }




exports.Layout =
  class Layout

    constructor: ->

    computePosition: (dim, constraints) -> throw new Error("unimplimented error")

    convertToCoordinate: (val, d) ->
      #console.log("converting to coordinate!!!!!!!!", val)
      if isPercentage val
        val = convertPercentageToFraction(val, d)
      else if isPositionLabel val
        #console.log("found a position label:", val)
        ret = positionToCoord(val, 0, 0, d[0], d[1], [0,0])
        #console.log("position coordinate", ret)
        ret
      else
        Math.min(val, d)


exports.AbsoluteLayout =
  class AbsoluteLayout extends exports.Layout

    computePosition: (dim, constraints) ->

      if _.isArray(constraints)
        ## assume coordinate array of length 2
        x = convertToCoordinate(constraints[0], dim[0])
        y = convertToCoordinate(constraints[1], dim[1])
        [x,y]
      else
        ## assume position label
        convertToCoordinate(constraints, dim)


#exports.DefaultLayout =
#class DefaultLayout extends exports.Layout


exports.GridLayout =
  class GridLayout extends exports.Layout

    constructor: (@rows, @cols, @bounds) ->
      @ncells = @rows*@cols
      @cells = @computeCells()

    computeCells: -> computeGridCells(@rows, @cols, @bounds)

    #cellPosition: (dim, constraints) ->

    computePosition: (dim, constraints) ->
      #if dim[0] != @bounds.width and dim[1] != @bounds.height
      #  @bounds.width = dim[0]
      #  @bounds.height = dim[1]
      #  @cells = @computeCells()
      if constraints[0] > (@rows-1)
        throw new Error("GridLayout.computePosition: illegal row position #{constraints[0]} for grid with dimensions (#{@rows}, #{@cols})")
      if constraints[1] > (@cols-1)
        throw new Error("GridLayout.computePosition: illegal column position #{constraints[0]} for grid with dimensions (#{@rows}, #{@cols})")

      cell = @cells[constraints[0]][constraints[1]]

      [cell.x + cell.width/2, cell.y + cell.height/2]

exports.positionToCoord = positionToCoord
exports.toPixels = toPixels