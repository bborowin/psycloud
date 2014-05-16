
html = require("./html")
{render, div, p, td, tr, table, input, caption} = require("teacup")

###<table id="likert">
<tr>
<td><input id="radGuiltyStart" type="radio" name="Guilty" value="1" /></td>
<td><input type="radio" name="Guilty" value="2" /></td>
<td><input type="radio" name="Guilty" value="3" /></td>
<td><input type="radio" name="Guilty" value="4" /></td>
<td><input id="radGuiltyEnd" type="radio" name="Guilty" value="5" /></td>
</tr>
     <tr>
         <td>Not Guilty</td>
<td>Hello</td>
         <td>hh</td>
<td>hh</td>
         <td>Very Guilty</td>
</tr>
  </table>###

class Likert extends html.HtmlStimulus

  defaults:
    choices: ["1", "2", "3"]
    fontSize: 16
    cellWidth: 200
    title: ""
    titleFontSize: 24


  constructor: (spec = {}) ->
    super(spec)
    @el.addClass(@spec.class)


    out = render =>
      spec = @spec

      table "#likert", ->
        caption spec.title
        tr ->
          for opt, index in spec.choices
            td ->
              input ("#radio_" + index), type: "radio", name: "scale", value: index + 1
        tr ->
          for opt in spec.choices
            td opt



    @html = $(out)
    @html.css("text-align", "center")
    @html.css("font-size", @spec.fontSize)
    @html.find("caption").css("font-size", @spec.titleFontSize)
    @html.css("border-spacing", 20)
    @html.css("table-layout", "fixed")
    @html.css("width", "300")

    #$("input[name='scale']").on("click", ->
    #  console.log("clicked from doc!")
    #)

    self = this
    @html.find("input[name='scale']").on("click", =>
      console.log("radio click")
      ind = $("#likert input[name='scale']:checked").val()
      console.log("index is", ind)
      console.log("this.emit is", self.emit)
      self.emit("likert_selection",
        value: ind
        choice: @spec.choices[ind-1]
      )
    )


    tdel = @html.find("td")
    tdel.css("width", @spec.cellWidth)
    tdel.css("overflow", "hidden")
    tdel.css("word-wrap", "break-word")

    @el.append(@html)


exports.Likert = Likert

###
spec = {}
spec.options = [1,2,3]
out = render ->
  table "likert", ->
    tr ->
      for opt, index in spec.options
        td ->
          input ("#radio_" + index), type: "radio", name: opt, value: index

          #input ("#radio_" + index), type: "radio", name: opt, value: index
          #input "hellp"

console.log(out)

###