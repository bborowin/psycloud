HtmlStimulus = require("./html").HtmlStimulus


class Page extends HtmlStimulus

  defaults:
    html: """<p>HTML Page</p>"""

  constructor: (spec = {}) ->
    super(spec)
    @el.append(@spec.html)



exports.Page = Page


