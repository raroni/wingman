Fleck = require 'fleck'
Module = require './../shared/module'
Events = require './../shared/events'

module.exports = class HasManyAssociation extends Module
  @include Events
  
  constructor: (@model, @associated_class) ->
    @model.observeOnce 'id', @setupScope
  
  setupScope: =>
    @scope = @associated_class.scoped @scopeOptions()
    @scope.bind 'add', (args...) => @trigger 'add', args...
    @scope.bind 'remove', (args...) => @trigger 'remove', args...
  
  scopeOptions: ->
    options = {}
    options[@foreignKey()] = @model.get 'id'
    options
  
  foreignKey: ->
    Fleck.underscore(@model.constructor.name) + '_id'
  
  count: ->
    if @scope
      @scope.count()
    else
      0
  
  forEach: (callback) ->
    callback(model) for model in @models()
    
  models: ->
    if @scope
      models = []
      models.push value for key, value of @scope.models
      models
    else
      []
