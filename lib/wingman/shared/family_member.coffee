Fleck = require 'fleck'
Wingman = require '../../wingman'

module.exports =
  pathKeys: ->
    return [] unless @constructor._name
    path_keys = [@constructor._name]
    path_keys = @parent.pathKeys().concat path_keys if @parent?.pathKeys?
    path_keys

  path: ->
    if @parent instanceof Wingman.App
      'root'
    else
      @pathKeys().join '.'
