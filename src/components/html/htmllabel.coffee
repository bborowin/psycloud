html = require("./html")

class HtmlLabel extends html.HtmlStimulus

  defaults:
    glyph: null, size: "large", text: "label", color: "orange"

  constructor: (spec = {}) ->
    super(spec)

    @el.addClass("ui " + @spec.color + " " + @spec.size +  " label")
    @el.append(@spec.text + " ")
    if @spec.glyph?
      @el.append("""
        <i class="#{@spec.glyph} #{@spec.size}  icon"></i>
      """)




exports.HtmlLabel = HtmlLabel