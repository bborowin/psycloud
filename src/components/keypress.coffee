Q = require("q")
Response = require("../stimresp").Response
ResponseData = require("../stimresp").ResponseData
utils = require("../utils")
_ = require('lodash')

keyTable =
    8: 'backspace'
    9: 'tab'
    13: 'enter'
    16: 'shift'
    17: 'ctrl'
    18: 'alt'
    20: 'capslock'
    27: 'esc'
    32: 'space'
    33: 'pageup'
    34: 'pagedown'
    35: 'end'
    36: 'home'
    37: 'left'
    38: 'up'
    39: 'right'
    40: 'down'
    45: 'ins'
    46: 'del'
    91: 'meta'
    93: 'meta'
    224: 'meta'
    106: '*'
    107: '+'
    109: '-'
    110: '.'
    111 : '/'
    186: ';'
    187: '='
    188: ','
    189: '-'
    190: '.'
    191: '/'
    192: '`'
    219: '['
    220: "\\"
    221: ']'


for i in [1...20]
  keyTable[111 + i] = 'f' + i

for i in [1..9]
  keyTable[i + 96]


class KeyResponse extends Response

  defaults:
    keys: ['1', '2'], correct: ['1'], timeout: null

  createResponseData: (timeStamp, startTime, Acc, char) ->
    resp =
      name: @name
      id: @id
      KeyTime: timeStamp
      RT: timeStamp - startTime
      Accuracy: Acc
      KeyChar: char

    resp


  resolveOnTimeout: (deferred, timeout) ->
    utils.doTimer(timeout, (diff) =>
      if !deferred.isResolved
        timeStamp = utils.getTimestamp()
        Acc = false
        resp = @createResponseData(timeStamp, @startTime, Acc, '')
        deferred.resolve(new ResponseData(resp))
    )




class KeyPress extends KeyResponse



  activate: (context) ->
    @startTime = utils.getTimestamp()
    deferred = Q.defer()
    keyStream = context.keypressStream()

    if @spec.timeout?
      @resolveOnTimeout(deferred, @spec.timeout)


    keyStream.filter((event) =>
      char = String.fromCharCode(event.keyCode)
      _.contains(@spec.keys, char)).take(1).onValue( (filtered) =>
      timeStamp = utils.getTimestamp()
      Acc = _.contains(@spec.correct, String.fromCharCode(filtered.keyCode))
      resp = @createResponseData(timeStamp, @startTime, Acc, String.fromCharCode(filtered.keyCode))

      deferred.resolve(new ResponseData(resp)))

    deferred.promise


exports.KeyPress = KeyPress


class SpaceKey extends Response
  # not DRY, need to abstract
  activate: (context) ->
    @startTime = utils.getTimestamp()
    deferred = Q.defer()
    keyStream = context.keypressStream()
    keyStream.filter((event) =>
      event.keyCode == 32).take(1).onValue((event) =>
      timeStamp = utils.getTimestamp()
      resp =
        name: "SpaceKey"
        id: @id
        KeyTime: timeStamp
        RT: timeStamp - @startTime
        KeyChar: "space"
      deferred.resolve(new ResponseData(resp)))

    deferred.promise

class AnyKey extends Response
  # not DRY, need to abstract
  activate: (context) ->
    @startTime = utils.getTimestamp()
    deferred = Q.defer()
    keyStream = context.keypressStream()
    keyStream.take(1).onValue((event) =>
      timeStamp = utils.getTimestamp()
      resp =
        name: "AnyKey"
        id: @id
        KeyTime: timeStamp
        RT: timeStamp - @startTime
        KeyChar: String.fromCharCode(event.keyCode)
      deferred.resolve(new ResponseData(resp)))

    deferred.promise


exports.SpaceKey = SpaceKey
exports.AnyKey = AnyKey