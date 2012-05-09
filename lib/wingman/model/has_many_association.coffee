Fleck = require 'fleck'
Wingman = require '../../wingman'
Events = require './../shared/events'

HasManyAssociation = Wingman.Object.extend
  initialize: (@model, @associatedClass) ->
    # TODO: tidy up with #synchronize or #synchronizeOnce?
    if @model.id
      @setupScope()
    else
      @model.observeOnce 'id', @setupScope.bind(@)
  
  foreignKey: ->
    result = undefined
    @associatedClass.belongsToNames.some (belongsToName) =>
      klassName = Fleck.upperCamelize belongsToName
      klass = Wingman.global[klassName]
      result = "#{belongsToName}Id" if klass == @model.constructor
    result
  
  setupScope: ->
    @scope = @associatedClass.scoped @scopeOptions()
    @scope.forEach (model) => @trigger 'add', model
    @scope.bind 'add', (args...) => @trigger 'add', args...
    @scope.bind 'remove', (args...) => @trigger 'remove', args...
  
  scopeOptions: ->
    options = {}
    options[@foreignKey()] = @model.get 'id'
    options
  
  count: ->
    if @scope
      @scope.count()
    else
      0
  
  buildOne: (hash) ->
    foreignId = @model.get 'id'
    throw new Error "Parent's ID must be set to use HasManyAssociation#build." unless foreignId
    hash[@foreignKey()] = foreignId
    @associatedClass.create hash
  
  build: (arrayOrHash) ->
    if Array.isArray(arrayOrHash)
      @buildOne hash for hash in arrayOrHash
    else
      @buildOne arrayOrHash
  
  forEach: (callback) ->
    callback(model) for model in @models()
    
  models: ->
    if @scope
      models = []
      models.push value for key, value of @scope.models
      models
    else
      []

HasManyAssociation.include Events

module.exports = HasManyAssociation