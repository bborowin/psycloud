html = require("./html")


class Slider extends html.HtmlStimulus

  defaults:
    min: 0, max: 100, value: 0, step: 1, height: 100, width: 300, id: "slider", showValue: true, fontSize: 20

  constructor: (spec = {}) ->
    super(spec)


    @slider = $(document.createElement("div")).attr("id", @spec.id)
    @slider.jqxSlider({ min: @spec.min, max: @spec.max, ticksFrequency: 25, value: 0, step: 25})
    @slider.css("margin-bottom", "10px")

    @el.append(@slider)

    if @spec.showValue
      @valueLabel = $(document.createElement("div")).attr("id", "valueLabel")
      @valueLabel.css("text-align", "center")
      @valueLabel.css("font-size", @spec.fontSize)
      @el.append(@valueLabel)

    @slider.on('change', (event) =>
      if @spec.showValue
        @valueLabel.text(event.args.value.toFixed(2))
    )



exports.Slider = Slider