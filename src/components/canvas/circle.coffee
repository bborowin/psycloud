#Kinetic = require("../../../jslibs/kinetic").Kinetic
KStimulus = require("../../stimresp").KineticStimulus
KDrawable = require("../../stimresp").KineticDrawable


# A circle graphical element
class Circle extends KStimulus

  defaults:
    x: 50, y: 50, radius: 50, fill: 'red', opacity: 1, origin: "center"


  # Construct a new Circle.
  #
  # @param [Object] spec component parameters
  # @option options [Int] x the x coordinate
  # @option options [Int] y the y coordinate
  # @option options [Int] radius the radius of the circle
  # @option options [Number] opacity the opacity of the Rectangle (0 is transparent, 1 opaque)
  # @option options [String] fill the color of the rectangle
  # @option options [String] stroke the color of the outline
  constructor: (spec = {}) ->
    super(spec)

  initialize: ->
    @circle = new Kinetic.Circle({ x: @spec.x, y: @spec.y, radius: @spec.radius, fill: @spec.fill, stroke: @spec.stroke, strokeWidth: @spec.strokeWidth, opacity: @spec.opacity })



  render: (context) ->
    coords = @computeCoordinates(context, @spec.position, @circle.getWidth(), @circle.getHeight())

    ## the origin of a circle in Kinetic.js is at the center of the circle, so the offset computation performed by computeCoodinates is incorrect.
    ## @computeCoordinates could take an extra argument that specifies whether origin is already at center of object.
    ## for now, we fix the offset by shifting the circle by 1/2 of the width and height
    @circle.setPosition({x: coords[0] + @circle.getWidth()/2, y: coords[1] + @circle.getHeight()/2})

    ## we override KineticDrawable to provide accurate numbers for circle bounding box.
    new (class extends KDrawable
      x: -> @node.getX() - @nodes[0].getWidth()/2
      y: -> @node.getY() - @nodes[0].getHeight()/2
      width: -> @node.getWidth()
      height: -> @node.getHeight()

    )(this, @circle)



exports.Circle = Circle