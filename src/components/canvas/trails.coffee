KStimulus = require("../../stimresp").KineticStimulus
#Kinetic = require("../../../jslibs/kinetic").Kinetic
utils = require("../../utils")


class TrailsA extends KStimulus

  defaults:
    npoints: 25, circleRadius: 25, circleFill: "blue"

  constructor: (spec) ->
    super(spec)

    @minDist = @spec.circleRadius * 4
    @circleRadius = @spec.circleRadius
    @npoints = @spec.npoints
    @maxIter = 100

  layoutPoints: (context) ->
    pts = utils.genPoints(@npoints, { x: @circleRadius, y: @circleRadius, width: context.width() - @circleRadius*2, height: context.height() - @circleRadius*2 })
    nn = utils.nearestNeighbors(pts, 1)[0]
    niter = 0
    while nn.distance < @minDist and niter < @maxIter
      id = nn.index[0]
      pts[id] = utils.genPoints(1, { x: @circleRadius, y: @circleRadius, width: context.width()- @circleRadius*2, height: context.height()- @circleRadius*2 })[0]
      nn = utils.nearestNeighbors(pts, 1)[0]
      niter++

    pts

  pathLength: (pts, newpt, i) ->
    pts = pts.slice(0)
    pts.splice(i,0,newpt)
    utils.pathLength(pts)

  minPathLength: (pts, newpt) ->
    lens = for i in [0...pts.length]
      @pathLength(pts, newpt, i)
    utils.whichMin(lens)

  orderPoints: (pts) ->
    ## list of point indices
    remaining = [0...pts.length]

    ## initialize with first point
    first = remaining[0]

    ## remove from set
    remaining.splice(first,1)

    path = [pts[first]]
    indices = [first]

    for index in remaining
      ## find the index
      insAt = @minPathLength(path, pts[index])
      path.splice(insAt,0,pts[index])

    path



  addCircleListener: (circle) ->
    outer = this
    circle.on "click", ->
      if this.attrs.id == "circle_".concat(outer.pathIndex + 1)
        if outer.pathIndex == (outer.npoints-1)
          this.fill("red")
          setTimeout((-> outer.emit("trail_completed")), 200)
        else
          this.fill("khaki")

        outer.emit("trail_move", {
          index: outer.pathIndex
          node_id: this.attrs.id
        })

        if outer.pathIndex == 0
          outer.path.points([this.getPosition().x, this.getPosition().y])
          outer.group.add(outer.path)
        else

          pts = outer.path.points()
          outer.path.points(pts.concat([this.getPosition().x, this.getPosition().y]))

        outer.pathIndex++
        context.draw()


  render: (context) ->
    @points = @orderPoints(@layoutPoints(context))
    @path = new Kinetic.Line({stroke: "khaki", strokeWidth: 2})
    @pathIndex = 0

    @group = new Kinetic.Group()

    for point, i in @points
      if i is 0
        circle = new Kinetic.Circle({ x: point[0], y: point[1], radius: @circleRadius, fill: @spec.circleFill, stroke: "khaki", strokeWidth: 2, id: "circle_" + (i+1)})
      else
        circle = new Kinetic.Circle({ x: point[0], y: point[1], radius: @circleRadius, fill: @spec.circleFill, id: "circle_" + (i+1)})

      @addCircleListener(circle)

      label = new Kinetic.Text({ x: point[0], y: point[1], text: (i+1), fontSize: 24, fontFamily: "Arial", fill: "white", listening: false})

      label.setPosition({x: circle.getPosition().x - label.getWidth()/2, y: circle.getPosition().y - label.getHeight()/2})

      @group.add(circle)
      @group.add(label)

    outer = this

    onPresent = (context) ->
      console.log("onPresent called!")



    @presentable(this, @group)



exports.TrailsA = TrailsA





