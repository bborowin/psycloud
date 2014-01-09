html = require("./html")

class HtmlIcon extends html.HtmlStimulus

  defaults:
    glyph: "plane", size: "massive"

  constructor: (spec = {}) ->
    super(spec)
    @html = $("<i></i>")
    @html.addClass(@spec.glyph + " " + @spec.size + " icon")
    @el.append(@html)


exports.HtmlIcon = HtmlIcon