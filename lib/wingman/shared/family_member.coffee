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
  
  createChildren: (type, options) ->
    for child_klass in @childClasses(type, options)
      object = new child_klass parent: @
      @setProperty child_klass._name, object
    
  childClasses: (type, options) ->
    classes = []
    source = options?.child_source || @
    for key, value of source.constructor
      match = key.match "(.*)#{type}$"
      if match && value != @constructor
        value._name = Fleck.underscore match[1]
        classes.push value
    classes
