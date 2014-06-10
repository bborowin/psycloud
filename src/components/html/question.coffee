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
    headerSize: "huge"
    headerFontColor: "black"
    headerInverted:  true


  inputElement: ->
    switch @spec.type
      when "dropdown" then new DropDown(@spec)
      when "multichoice" then new MultiChoice(@spec)
      when "textfield" then new TextField(@spec)
      else throw new Error("Question: illegal type argument --  " + @spec.type)


  hasChildren: -> true

  getChildren: -> [@question]


  constructor: (spec = {}) ->
    super(spec)

  #initReactions: ->
  #  for key, value of @react
  #    console.log("listening for", key, "with", value)
  #    @question.on(key, value)

  addReaction: (name, fun, selector) ->
    # TODO check that "name" is a valid signal
    if not selector?
      @question.on(name,fun)
    else
      if selector.id is this.id
        @question.on(name,fun)


  initialize: ->
    @el = @div()
    @question = @inputElement()

    headerClass = =>
      header = "ui " + @spec.headerSize + " top attached " + @spec.headerFontColor
      if @spec.headerInverted
        header = header + " inverted block header"
      else
        header = header + " block header"

    hclass = headerClass()

    @title = $("""<h4 class="#{hclass}">""").text(@spec.question)
    @segment = $("""<div class="ui segment attached">""")

    content = @question.el
    console.log("content is", content)

    @segment.append(content)

    @el.append(@title)
    @el.append(@segment)

    @el.css("width", "95%")
    @el.css("padding-bottom", @spec.paddingBottom + "px")











exports.Question = Question