Fleck = require 'fleck'
WingmanObject = require './shared/object'

module.exports = class extends WingmanObject
  constructor: (@parent, @type, options) ->
    @child_source = options?.child_source
    for child_klass in @childClasses()
      target = if options?.attach_to == 'tree' then @ else @parent
      object = new child_klass parent: @parent
      target.setProperty child_klass._name, object
  
  childClasses: ->
    classes = []
    for key, value of (@child_source || @parent).constructor
      match = key.match "(.*)#{@type}$"
      if match && value != @parent.constructor
        value._name = Fleck.underscore match[1]
        classes.push value
    classes
