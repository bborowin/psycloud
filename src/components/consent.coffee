Stimulus = require("../stimresp").Stimulus
Drawable = require("../stimresp").Drawable
#Kinetic = require("../../jslibs/kinetic").Kinetic
layout = require("../layout")

Markdown = require("./html/markdown").Markdown
CheckBox = require("./html/checkbox").CheckBox
Page = require("./html/page").Page

class Consent extends Stimulus

  constructor: (spec={}) ->
    super(spec)
    if @spec.url.endsWith(".md")
      @content = new Markdown({url: @spec.url})
    else if @spec.url.endsWith(".html")
      @content = new Page({url: @spec.url})

    @checkbox = new CheckBox(label: "I consent to participate in this study")

    @el = $(document.createElement("div"))

    (=>
      @el.append(@content.element())

      check = @checkbox.element()
      #check.css("padding-bottom", "10px")
      #check.input.css("padding", "10px")
      @el.append(check)
    ).delay(2000)

    @el.css("margin-bottom", "15px")
    #@el.css("overflow-y",  "scroll")


    outer = this
    @checkbox.on("checked", ->
      console.log("received consent!")
      outer.emit("consent")
    )



  presentable: (element) ->


    new (class extends Drawable

      constructor: (@element) ->

      x: -> @element.position().left

      y: -> @element.position().top

      width: -> @element.width()

      height: -> @element.height()

      present: (context) ->
        context.appendHtml(@element)
        @element.show()

    )(element)



  render: (context) -> @presentable(@el)

exports.Consent = Consent