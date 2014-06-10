html = require("./html")

class CheckBox extends html.HtmlStimulus

  defaults:
    label: "click here"
    class: ""

  initialize: ->
    @el.addClass "ui large checkbox"
    @input = $("<input type=\"checkbox\" id=\"mycheckbox\">")
    @label = $("<label></label>").text(@spec.label)
    @label.attr "for", "mycheckbox"
    @el.append @input
    @el.append @label
    @el.addClass @spec["class"]
    outer = this
    @input.on "change", ->
      console.log "detected checkbox event"
      if $(this).is(":checked")
        console.log "emitting checked outer event"
        outer.emit "checked"
      else
        console.log "emitting unchecked outer event"
        outer.emit "unchecked"

      return


exports.CheckBox = CheckBox
