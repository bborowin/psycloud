
GStimulus = require("../../stimresp").GraphicalStimulus
ActionPresentable = require("../../stimresp").ActionPresentable

# clears the content of the canvas
class Clear extends GStimulus

  render: (context) ->
    action = (ctx) =>
      context.clearContent(true)

    new ActionPresentable(action)


exports.Clear = Clear