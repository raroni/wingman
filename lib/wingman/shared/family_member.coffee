Fleck = require 'fleck'
Wingman = require '../../wingman'

module.exports =
  pathKeys: ->
    return [] unless @constructor._name
    path_keys = [@constructor._name]
    path_keys = @get('parent').pathKeys().concat path_keys if @get('parent')?.pathKeys?
    path_keys

  path: ->
    if @get('parent') instanceof Wingman.Application
      'root'
    else
      @pathKeys().join '.'
  
  familize: (type, options) ->
    @setProperty key, value for key, value of options?.options
    @createChildren type, options
  
  createChildren: (type, options) ->
    for child_klass in @childClasses(type, options)
      object = new child_klass parent: @, children: { options: options?.options }
      @setProperty child_klass._name, object
    
  childClasses: (type, options) ->
    classes = []
    source = options?.source || @
    for key, value of source.constructor
      match = key.match "(.*)#{type}$"
      if match && value != @constructor
        value._name = Fleck.underscore match[1]
        classes.push value
    classes
