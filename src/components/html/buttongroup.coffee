html = require("./html")
_ = require("lodash")

class ButtonGroup extends html.HtmlStimulus

  description: "An set of html button aligned in a row or column."

  defaults:
    labels: [], margin: 2, size: "large"

  signals: ["clicked"]

  constructor: (spec = {}) ->
    super(spec)

  initialize: ->
    super()
    @el = @div()

    @el.addClass(@spec.size + " ui buttons")

    outer = this
    _.forEach(@spec.labels, (label) =>
      div = @div()
      div.addClass("ui button")
      div.append(label)
      div.css("margin", @spec.margin)

      div.on("click", ->
        console.log("emitting button group clicked with label", label)
        outer.emit("clicked", {
          id: outer.id
          source: outer
          label: label
          name: outer.name
        })
      )

      @el.append(div)
    )







exports.ButtonGroup = ButtonGroup