html = require("./html")
DropDown = require("./dropdown").DropDown
MultiChoice = require("./multichoice").MultiChoice
TextField = require("./textfield").TextField


{render, div, p, td, tr, table, input, label, h4} = require("teacup")

class Question extends html.HtmlStimulus

  defaults:
    question: "What is your name?"
    type: "dropdown"
    paddingBottom: 15


  inputElement: ->
    switch @spec.type
      when "dropdown" then new DropDown(@spec)
      when "multichoice" then new MultiChoice(@spec)
      when "textfield" then new TextField(@spec)
      else throw new Error("Question: illegal type argument --  " + @spec.type)


  constructor: (spec = {}) ->
    super(spec)




  initialize: ->
    @el = @div()
    @question = @inputElement()

    @title = $("""<h4 class="ui top attached block header">""").text(@spec.question)
    @segment = $("""<div class="ui segment attached">""")

    content = @question.el

    @segment.append(content)

    @el.append(@title)
    @el.append(@segment)

    @el.css("width", "95%")
    @el.css("padding-bottom", @spec.paddingBottom + "px")

    outer = this

    @question.on("change", (args) =>
      outer.emit("change", args)
    )




exports.Question = Question