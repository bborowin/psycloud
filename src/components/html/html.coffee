GStimulus = require("../../stimresp").GraphicalStimulus
Drawable= require("../../stimresp").Drawable
Response = require("../../stimresp").Response
Mixen = require("mixen")
#$ = require("jqueryify")



class HtmlMixin

  tag: "div"

  div: -> $(document.createElement("div"))

  constructor: () ->
    @el = document.createElement(@tag)
    @el  = $(@el)

  positionElement: (el, x, y) ->
    el.css({
      position: "absolute"
      left: x
      top: y
    })

  centerElement: (el) ->
    el.css({
      margin: "0 auto"
      position: "absolute"
      left: "50%"
      top: "50%"
    })



HMixStim = Mixen(HtmlMixin,GStimulus)
HMixResp =  Mixen(HtmlMixin,Response)

class HtmlStimulus extends HMixStim
  constructor: (spec) ->
    super(spec)

  presentable: (element) ->
    new (class extends Drawable

      constructor: (@element) ->

      x: -> @element.position().left

      y: -> @element.position().top

      width: -> @element.width()

      height: -> @element.height()

      present: (context) -> @element.show()

    )(element)

  render: (context) ->
    console.log("rendering html stimulus", @name)

    @el.hide()
    context.appendHtml(@el)
    console.log("@spec.position",  @spec.position)
    console.log("@spec.x",  @spec.x)
    console.log("@spec.y",  @spec.y)
    console.log("@el width", @el.width())
    console.log("@el height", @el.height())
    coords = @computeCoordinates(context, @spec.position, @el.width(), @el.height())
    console.log("coords", coords)
    @positionElement(@el, coords[0], coords[1])

    @presentable(@el)
    #@el.show()

    #super(context, layer)

class HtmlResponse extends HMixResp
  constructor: () ->
    super


exports.HtmlStimulus = HtmlStimulus
exports.HtmlResponse = HtmlResponse



Html = {}
Html.HtmlButton = require("./htmlbutton").HtmlButton
Html.HtmlLink = require("./htmllink").HtmlLink
Html.HtmlLabel = require("./htmllabel").HtmlLabel
Html.HtmlIcon = require("./htmlicon").HtmlIcon
Html.Instructions = require("./instructions").Instructions
Html.Markdown = require("./markdown").Markdown
Html.Message = require("./message").Message
Html.Page = require("./page").Page
Html.HtmlResponse = HtmlResponse
Html.HtmlStimulus = HtmlStimulus






exports.Html = Html