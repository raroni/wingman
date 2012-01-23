Fleck = require 'fleck'
WingmanObject = require './shared/object'

module.exports = class extends WingmanObject
  constructor: (@source, @type, options) ->
    for child_klass in @childClasses()
      target = if options?.attach_to == 'tree' then @ else @source
      object = new child_klass parent: @source
      target.setProperty child_klass._name, object
  
  childClasses: ->
    classes = []
    for key, value of @source.constructor
      match = key.match "(.*)#{@type}$"
      if match
        value._name = Fleck.underscore match[1]
        classes.push value
    classes
