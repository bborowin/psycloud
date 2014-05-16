GStimulus = require("../../stimresp").GraphicalStimulus
Drawable= require("../../stimresp").Drawable
Response = require("../../stimresp").Response
Mixen = require("mixen")
signals = require("smokesignals")
#$ = require("jqueryify")



class HtmlMixin

  tag: "div"

  div: -> $(document.createElement("div"))

  constructor: () ->
    @el = document.createElement(@tag)
    @el  = $(@el)

  positionElement: (el, x, y) ->
    el.css({
      position: "relative"
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
    #should not be necessary?
    super(spec)
    signals.convert(this)

  element: -> @el

  html: -> $('<div>').append(@element()).html()

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
    @el.hide()

    # TODO inconsistency here. html elements are added at rendering stage, Kinetic objects are not...
    context.appendHtml(@el)
    coords = @computeCoordinates(context, @spec.position, @el.width(), @el.height())
    @positionElement(@el, coords[0], coords[1])
    @presentable(@el)


class HtmlResponse extends HMixResp
  constructor: () ->
    super


exports.HtmlStimulus = HtmlStimulus
exports.HtmlResponse = HtmlResponse



Html = {}
Html.HtmlButton = require("./htmlbutton").HtmlButton
Html.CheckBox = require("./checkbox").CheckBox
Html.HtmlLink = require("./htmllink").HtmlLink
Html.HtmlLabel = require("./htmllabel").HtmlLabel
Html.HtmlIcon = require("./htmlicon").HtmlIcon
Html.Instructions = require("./instructions").Instructions
Html.Markdown = require("./markdown").Markdown
Html.Message = require("./message").Message
Html.Page = require("./page").Page
Html.HtmlRange = require("./htmlrange").HtmlRange
Html.HtmlResponse = HtmlResponse
Html.HtmlStimulus = HtmlStimulus
Html.Likert = require("./likert").Likert
Html.Slider = require("./slider").Slider
Html.TextField = require("./textfield").TextField
Html.DropDown = require("./dropdown").DropDown
Html.MultiChoice = require("./multichoice").MultiChoice
Html.Question = require("./question").Question
exports.Html = Html