Wingman = require '../wingman'
WingmanObject = require './shared/object'
StorageAdapter = require './model/storage_adapter'
Store = require './model/store'
Scope = require './model/scope'
HasManyAssociation = require './model/has_many_association'
Fleck = require 'fleck'

module.exports = class Model extends WingmanObject
  @extend StorageAdapter
  
  @store: ->
    @_store ||= new Store
  
  @count: ->
    @store().count()
  
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
    new Scope @store(), params
  
  @find: (id) ->
    @store().find id
  
  constructor: (properties, options) ->
    @storageAdapter = @constructor.storageAdapter()
    @dirtyStaticPropertyNames = []
    @setupHasManyAssociations() if @constructor.hasManyNames
    @observeOnce 'id', =>
      @constructor.store().add @
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
