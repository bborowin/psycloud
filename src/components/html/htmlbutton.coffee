html = require("./html")


class HtmlButton extends html.HtmlStimulus

  description: "An html button that can be clicked."

  defaults:
    label: "Next", class: ""

  signals: ["clicked"]

  constructor: (spec = {}) ->
    super(spec)

  initialize: ->
    super()
    @el = @div()
    @el.addClass("ui button")
    @el.addClass(@spec.class)
    @el.append(@spec.label)
    #@positionElement(@el)

    outer = this
    @el.on("click", =>
      console.log("emitting clicked")
      outer.emit("clicked", {
          id: outer.id
          source: this
          label: @spec.label
          name: @name
        }
      )
    )



    #@initReactions(outer)



exports.HtmlButton = HtmlButton