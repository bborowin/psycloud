
#exports.DefaultComponentFactory = require("./factory").DefaultComponentFactory
#exports.componentFactory = require("./factory").componentFactory
exports.Sound = require("./sound").Sound
exports.Confirm = require("./confirm").Confirm
exports.First = require("./first").First
exports.Group = require("./group").Group
exports.CanvasGroup = require("./group").CanvasGroup
exports.Grid = require("./group").Grid
KP = require("./keypress")
exports.KeyPress = KP.KeyPress
exports.SpaceKey = KP.SpaceKey
exports.AnyKey = KP.AnyKey
exports.MousePress = require("./mousepress").MousePress
exports.Prompt = require("./prompt").Prompt
exports.Sequence = require("./sequence").Sequence
exports.Timeout = require("./timeout").Timeout
exports.Click = require("./click").Click
exports.Nothing = require("./nothing").Nothing
exports.Receiver = require("./receiver").Receiver
exports.Consent = require("./consent").Consent

#console.log("ZZZ exports.DefaultComponentFactory", require("./factory").DefaultComponentFactory)