_ = require('lodash')
Q = require("q")


class Query extends require("../stimresp").Response

  defaults:
    select: {}
    filter: {}

  constructor: (spec) ->
    super(spec)

  activate: (context) ->
    ret = if _.isEmpty(@spec.filter)
      context.userData()
    else
      context.userData().filter({ blockNumber: args.blockNum })

    ret = if not _.isEmpty(@spec.select)
      ret.select(@spec.select)

    Q(ret)


exports.Query = Query