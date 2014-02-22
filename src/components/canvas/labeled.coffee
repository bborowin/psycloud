Kinetic = require("../../../jslibs/kinetic").Kinetic
Text = require("./Text").Text
StimResp = require("../../stimresp")

class LabeledElement extends StimResp.Stimulus


  defaults:
    position: "below", content: "Label", align: "center", gap: 10, fontSize: 32, fill: "black", fontFamily: "Arial"

  # Construct a new LabeledElement.
  #
  # @param [Stimulus] element the element to label
  # @param [Object] spec component parameters
  # @option options [String] position the relative position of the label
  constructor: (@element, spec = {}) ->
    super(spec)

  render: (context) ->

    target = @element.render(context)

    @text = new Kinetic.Text({
      x: 0
      y: 0
      text: @spec.content
      fontSize: @spec.fontSize
      fill: @spec.fill
      align: @spec.align
      width: target.width()
      fontFamily: @spec.fontFamily
      padding: 2
    })

    console.log("labeled text", @text.getPosition())

    console.log("labeled target width:", target.width())
    console.log("labeled target height:", target.height())


    switch @spec.position
      when "below" then @text.setPosition({x: target.x(), y: target.y() + target.height() + @spec.gap})
      when "above" then @text.setPosition({x: target.x(), y: target.y() - @text.getTextHeight()})
      when "left" then @text.setPosition({x: target.x() - @text.getTextWidth() - @spec.gap, y: target.y()})
      when "right" then @text.setPosition({x: target.x() + target.width() + @spec.gap, y: target.y()})


    new StimResp.ContainerDrawable([target, new StimResp.KineticDrawable(@text)])



exports.LabeledElement = LabeledElement