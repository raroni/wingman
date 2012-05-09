Wingman = require '../wingman'
StorageAdapter = require './model/storage_adapter'
HasManyAssociation = require './model/has_many_association'
Fleck = require 'fleck'

Prototype =
  id: null
  
  initialize: (hash) ->
    @setupHasManyAssociations() if @constructor.hasManyNames
      
    @[key] = value for key, value of hash
    collectionAdd = => @constructor.collection().add @
    
    # TODO: tidy up with #synchronize or #synchronizeOnce?
    if @id
      collectionAdd()
    else
      @observeOnce 'id', collectionAdd
    
    @_super()
  
  setupBelongsToAssociations: ->
    @setupBelongsToAssociation belongsToName for belongsToName in @constructor.belongsToNames
  
  getStorageAdapter: ->
    @constructor.storageAdapter()
  
  setupHasManyAssociations: ->
    @setupHasManyAssociation hasManyName for hasManyName in @constructor.hasManyNames
  
  setupHasManyAssociation: (hasManyName) ->
    klassName = Fleck.camelize(Fleck.singularize(Fleck.underscore(hasManyName)), true)
    
    klass = Wingman.global[klassName]
    association = HasManyAssociation.create @, klass
    
    @[hasManyName] = association
    
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
  
  setProperty: (propertyName, values) ->
    throw new Error 'You cannot change the ID of a model when set.' if propertyName == 'id' && @get('id')
    if @[propertyName] instanceof HasManyAssociation
      @[propertyName].build values
    else
      @_super propertyName, values
      if propertyName != 'storage'
        @dirtyStaticPropertyNames.push propertyName
        @save() if @isInstance() && @storageAdapter.autoSave
  
  getDirtyStaticPropertyNames: ->
    @_dirtyStaticPropertyNames = []  unless @hasOwnProperty '_dirtyStaticPropertyNames'
    @_dirtyStaticPropertyNames
  
  isPersisted: ->
    !!@get('id')
  
  isDirty: ->
    @dirtyStaticPropertyNames.length != 0

ClassProperties =
  collection: ->
    Wingman.store().collection @
  
  count: ->
    @collection().count()
  
  load: (args...) ->
    if typeof(args[0]) == 'number'
      @loadOne args[0], args[1]
    else
      @loadMany args[0]
  
  hasMany: (name) ->
    (@hasManyNames ||= []).push name
    @registerProperties name
  
  belongsTo: (name) ->
    (@belongsToNames ||= []).push name
    @registerProperties name, name + 'Id'
  
  registerProperties: (args...) ->
    hash = {}
    hash[propertyName] = null for propertyName in args
    @prototype.include hash
  
  loadOne: (id, callback) ->
    @storageAdapter().load id, success: (hash) =>
      model = @create hash
      callback model if callback
  
  loadMany: (callback) ->
    @storageAdapter().load success: (array) =>
      models = []
      for modelData in array
        model = @create modelData
        models.push model
      callback models if callback
  
  scoped: (params) ->
    @collection().scoped params
  
  find: (id) ->
    @collection().find id

Model = Wingman.Object.extend Prototype, ClassProperties
Model.include StorageAdapter

module.exports = Model
