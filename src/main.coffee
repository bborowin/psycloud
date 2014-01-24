Exp = require("./elements")
Psy = require("./psycloud")
Dots = require("./dotmotion")
utils = require("./utils")
datatable = require("./datatable")
samplers = require("./samplers")
stimresp = require("./stimresp")
layout = require("./layout")
design = require("./design")
canvas = require("./components/canvas/canvas")
html = require("./components/html/html")
components = require("./components/components")
factory = require("./factory")
Kinetic = require("../jslibs/kinetic").Kinetic
_ = require('lodash')
Q = require("q")
csv = require('../jslibs/jquery.csv.js')


include = (lib) ->
  for key, value of lib
    exports[key] = value

#libs = [Exp, Psy, Dots, utils, datatable, samplers, stimresp, layout]

libs = [Exp, Psy, Dots, utils, datatable, samplers, stimresp, layout, design, canvas, html, components, factory]

for lib in libs
  include(lib)


exports.Q = Q
exports._ = _
exports.Kinetic = Kinetic
exports.csv = csv
#exports.recline = recline


if not String.prototype.trim
  String.prototype.trim = ->
    this.replace(/^\s+|\s+$/g,'')



