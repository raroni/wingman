Wingman = require '../wingman'
StorageAdapter = require './model/storage_adapter'
HasManyAssociation = require './model/has_many_association'
Fleck = require 'fleck'

module.exports = class Model extends Wingman.Object
  @extend StorageAdapter
  
  @collection: ->
    Wingman.store().collection @
  
  @count: ->
    @collection().count()
  
  @load: (args...) ->
    if typeof(args[0]) == 'number'
      @loadOne args[0], args[1]
    else
      @loadMany args[0]
  
  @hasMany: (name) ->
    (@hasManyNames ||= []).push name
  
  @loadOne: (id, callback) ->
    @storageAdapter().load id, success: (hash) =>
      model = new @ hash
      callback model if callback

  @loadMany: (callback) ->
    @storageAdapter().load success: (array) =>
      models = []
      for modelData in array
        model = new @ modelData
        models.push model
      callback models if callback
  
  @scoped: (params) ->
    @collection().scoped params
  
  @find: (id) ->
    @collection().find id
  
  constructor: (properties, options) ->
    @storageAdapter = @constructor.storageAdapter()
    @dirtyStaticPropertyNames = []
    @setupHasManyAssociations() if @constructor.hasManyNames
    @observeOnce 'id', =>
      @constructor.collection().add @
    @set properties
  
  setupHasManyAssociations: ->
    for hasManyName in @constructor.hasManyNames
      klassName = Fleck.camelize(Fleck.singularize(Fleck.underscore(hasManyName)), true)
      
      klass = Wingman.global[klassName]
      association = new HasManyAssociation @, klass
      @setProperty hasManyName, association
      association.bind 'add', (model) => @trigger "add:#{hasManyName}", model
      association.bind 'remove', (model) => @trigger "remove:#{hasManyName}", model
  
  save: (options = {}) ->
    operation = if @isPersisted() then 'update' else 'create'
    @storageAdapter[operation] @,
      success: (data) =>
        if data
          delete data.id if operation == 'update'
          @set data
        @clean()
        options.success?()
      error: -> options.error?()
  
  destroy: ->
    @trigger 'destroy', @
    @storageAdapter.delete @get('id')
    @flush()
  
  flush: ->
    @trigger 'flush', @
  
  toParam: ->
    @get 'id'
  
  load: ->
    @storageAdapter.load @get('id'), success: (hash) =>
      delete hash.id
      @set hash
  
  clean: ->
    @dirtyStaticPropertyNames.length = 0
  
  dirtyStaticProperties: ->
    @toJSON only: @dirtyStaticPropertyNames
  
  set: (hash) ->
    super hash
  
  setProperty: (propertyName, values) ->
    throw new Error 'You cannot change the ID of a model when set.' if propertyName == 'id' && @get('id')
    
    if @get(propertyName) instanceof HasManyAssociation
      @get(propertyName).build values
    else
      @dirtyStaticPropertyNames.push propertyName
      super propertyName, values
      @save() if @storageAdapter.autoSave
  
  isPersisted: ->
    !!@get('id')
  
  isDirty: ->
    @dirtyStaticPropertyNames.length != 0
  