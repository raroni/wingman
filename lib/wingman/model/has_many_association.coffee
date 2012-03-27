Fleck = require 'fleck'
Module = require './../shared/module'
Events = require './../shared/events'

module.exports = class HasManyAssociation extends Module
  @include Events
  
  constructor: (@model, @associatedClass) ->
    @model.observeOnce 'id', @setupScope
  
  setupScope: =>
    @scope = @associatedClass.scoped @scopeOptions()
    @scope.forEach (model) => @trigger 'add', model
    @scope.bind 'add', (args...) => @trigger 'add', args...
    @scope.bind 'remove', (args...) => @trigger 'remove', args...
  
  scopeOptions: ->
    options = {}
    options[@foreignKey()] = @model.get 'id'
    options
  
  foreignKey: ->
    Fleck.camelize(Fleck.underscore(@model.constructor.name)) + 'Id'
  
  count: ->
    if @scope
      @scope.count()
    else
      0
  
  buildOne: (hash) ->
    foreignId = @model.get('id')
    throw new Error "Parent's ID must be set to use HasManyAssociation#build." unless foreignId
    hash[@foreignKey()] = foreignId
    new @associatedClass hash
  
  build: (arrayOrHash) ->
    array = if Array.isArray(arrayOrHash)
      arrayOrHash
    else
      [arrayOrHash]
    
    @buildOne hash for hash in array
  
  forEach: (callback) ->
    callback(model) for model in @models()
    
  models: ->
    if @scope
      models = []
      models.push value for key, value of @scope.models
      models
    else
      []
