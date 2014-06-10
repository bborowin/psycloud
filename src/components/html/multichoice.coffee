html = require("./html")
_ = require("lodash")

{render, div, p, td, tr, table, input, label} = require("teacup")

###
  <div class="ui form">
  <div class="grouped inline fields">
    <div class="field">
      <div class="ui radio checkbox">
        <input type="radio" name="fruit" checked="checked">
        <label>Apples</label>
      </div>
    </div>
    <div class="field">
      <div class="ui radio checkbox">
        <input type="radio" name="fruit">
        <label>Oranges</label>
      </div>
    </div>

  </div>
</div>
###
class MultiChoice extends html.HtmlStimulus

  defaults:
    choices: ["1", "2", "3", "4"]

  signals: ["change"]

  renderForm: ->
    outer = this
    form = render =>
      spec = @spec

      div "#multichoice.ui.form", ->
        div ".grouped.inline.fields", ->
          for choice in spec.choices
            div ".field", ->
              div ".ui.radio.checkbox", ->
                input ("#" + choice), type: "radio", name: "multichoice_" + outer.id, id: choice
                label choice


    $(form)


  constructor: (spec = {}) ->
    super(spec)
    if _.unique(@spec.choices).length != @spec.choices.length
      throw new Error("MultiChoice: no duplicate elements allowed in 'choices' argument")




  initialize: ->
    outer = this
    @el = @div()
    @form = @renderForm()
    @el.append(@form)

    @el.find('.ui.radio.checkbox').checkbox({
      onChange: ->
        outer.emit("change", $(this).attr("id"))
    })





  #render: (context) ->
  #  outer = this
  #  super(context)




exports.MultiChoice = MultiChoice