Kinetic = require("../../../jslibs/kinetic").Kinetic
KStimulus = require("../../stimresp").KineticStimulus

class Picture extends KStimulus
  defaults:
    url: "http://www.html5canvastutorials.com/demos/assets/yoda.jpg", x: 0, y: 0

  constructor: (spec = {}) ->
    super(spec)

    @imageObj = new Image()
    @image = null

    @imageObj.onload = =>
      @image = new Kinetic.Image({
        x: @spec.x,
        y: @spec.y,
        image: @imageObj,
        width: @spec.width or @imageObj.width,
        height: @spec.height or @imageObj.height
      })



    @imageObj.src = @spec.url


  render: (context) -> @presentable(@image)


exports.Picture = Picture

