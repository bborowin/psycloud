html = require("./html")
marked = require("marked")
_ = require('lodash')


class Markdown extends html.HtmlStimulus

  constructor: (spec = {}) ->
    super(spec)
    if _.isString(spec)
      @spec = {}
      @spec.x=0
      @spec.y=0
      @spec.content = spec

    if @spec.url?
      console.log("trying to load url", @spec.url)
      $.ajax(
        url: @spec.url
        success: (result) =>
          console.log("successfully loaded markdown", result)
          @spec.content = result
          @el.append(marked(@spec.content))
        error: (result) =>
          console.log("ajax failure", result)
      )
    else
      @el.append($(marked(@spec.content)))

    @el.addClass("markdown")
    #@el.children().addClass("markdown")



exports.Markdown = Markdown