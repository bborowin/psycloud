html = require("./html")


class DropDown extends html.HtmlStimulus

  defaults:
    choices: ["male", "female"]
    name: ""

  signals: ["change"]

  constructor: (spec = {}) ->
    super(spec)

    ###
    <div class="ui selection dropdown">
      <input type="hidden" name="gender">
      <div class="default text">Gender</div>
      <i class="dropdown icon"></i>
      <div class="menu">
        <div class="item" data-value="1">Male</div>
        <div class="item" data-value="0">Female</div>
      </div>
    </div>

    ###

    #out = render =>
    #  spec = @spec
    #
    #  div ".ui.selection.dropdown", ->
    #    input type: "hidden", name: spec.name
    #    div ""
    #      for choice in spec.choices
    #        div ".field", ->
    #          div ".ui.radio.checkbox", ->
    #            input ("#" + choice), type: "radio", name: "multichoice_" + outer.id, id: choice
    #            label choice


  initialize: ->
    @el = @div()
    @el.addClass("ui selection dropdown")

    @input = $("""<input type="hidden" name="#{@spec.name}">""")
    defaultText = @div().text(@spec.name).addClass("default text")
    icon = $("""<i class="dropdown icon"></i>""")

    menu = @div().addClass("menu")
    for choice in @spec.choices
      item = @div()
      item.addClass("item")
      item.attr("data-value", choice)
      item.text(choice)
      menu.append(item)

    @el.append(@input)
    @el.append(defaultText)
    @el.append(icon)
    @el.append(menu)

    outer = this

    @el.dropdown({
      onChange: (newval) ->
        outer.emit("change",  {
          id: outer.id
          val: newval
          source: outer
          name: outer.name
        })
    })




#@positionElement(@el)


exports.DropDown = DropDown