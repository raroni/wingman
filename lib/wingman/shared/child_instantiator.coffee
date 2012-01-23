Fleck = require 'fleck'
Wingman = require '../../wingman'

module.exports =
  pathKeys: ->
    return [] unless @parent?.pathKeys?
    path_keys = [@constructor._name]
    path_keys.unshift path_key for path_key in @parent.pathKeys()
    path_keys
    
  path: ->
    @pathKeys().join '.'
  
  deactivateDescendantsExceptChild: (controller_name) ->
    # This is both ugly and slow. Should be refactored!
    
    for name, controller of (@controllers || @)
      if controller instanceof Wingman.Controller && controller_name != name
        controller.deactivate()
    
    @parent?.deactivateDescendantsExceptChild @constructor._name
