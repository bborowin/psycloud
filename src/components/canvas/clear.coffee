
GStimulus = require("../../stimresp").GraphicalStimulus
ActionPresentable = require("../../stimresp").ActionPresentable

# clears the content of the canvas
class Clear extends GStimulus

  render: (context) ->
    new ActionPresentable( (context) -> context.clearContent(true))


exports.Clear = Clear