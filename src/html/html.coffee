GStimulus = require("../../stimresp").GraphicalStimulus
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
    console.log("placing element at", x, y)
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

  #render: (context, layer) ->
  #  console.log("element width is", @el.width())
  #  console.log("element height is", @el.height())
  #  coords = @computeCoords(context, @spec.position, @el.width(), @el.height())
  #  positionElement(@el, coords[0], coords[1])
  #  context.appendHtml(@el)
  #  super(context, layer)


HMixStim = Mixen(HtmlMixin,GStimulus)
HMixResp =  Mixen(HtmlMixin,Response)

class HtmlStimulus extends HMixStim
  constructor: () ->
    super

  render: (context) ->
    console.log("RENDERING HTML STIMULUS!!!!")
    @el.hide()
    context.appendHtml(@el)
    coords = @computeCoordinates(context, @spec.position, @el.width(), @el.height())
    console.log("coords", coords)
    console.log("positioning html element")
    @positionElement(@el, coords[0], coords[1])
    @el.show()
    console.log("element width is", @el.width())
    console.log("element height is", @el.height())
    console.log("spec.position", @spec.position)
    console.log("spec.x", @spec.x)
    console.log("spec.y", @spec.y)

    super(context)

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