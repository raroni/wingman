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
    (@has_many_names ||= []).push name
  
  @loadOne: (id, callback) ->
    @storageAdapter().load id, success: (hash) =>
      model = new @ hash
      callback model if callback

  @loadMany: (callback) ->
    @storageAdapter().load success: (array) =>
      models = []
      for model_data in array
        model = new @ model_data
        models.push model
      callback models if callback
  
  @scoped: (params) ->
    new Scope @store(), params
  
  constructor: (properties, options) ->
    @storage_adapter = @constructor.storageAdapter()
    @dirty_static_property_names = []
    @setupHasManyAssociations() if @constructor.has_many_names
    @observeOnce 'id', =>
      @constructor.store().add @
    @set properties
  
  setupHasManyAssociations: ->
    for has_many_name in @constructor.has_many_names
      klass_name = Fleck.camelize Fleck.singularize(has_many_name), true
      
      # Ideally, we should not require an app to be instantiated to find other model classes.
      # But for now I cannot come up with a better solution than to find the model classes in the current apps constructor.
      klass = Wingman.Application.instance.constructor[klass_name]
      association = new HasManyAssociation @, klass
      @setProperty has_many_name, association
      association.bind 'add', (model) => @trigger "add:#{has_many_name}", model
      association.bind 'remove', (model) => @trigger "remove:#{has_many_name}", model
  
  save: (options = {}) ->
    operation = if @isPersisted() then 'update' else 'create'
    @storage_adapter[operation] @,
      success: (data) =>
        if data
          delete data.id if operation == 'update'
          @set data
        @clean()
        options.success?()
      error: -> options.error?()
  
  destroy: ->
    @trigger 'destroy', @
    @storage_adapter.delete @get('id')
  
  toParam: ->
    @get 'id'
  
  load: ->
    @storage_adapter.load @get('id'), success: (hash) =>
      delete hash.id
      @set hash
  
  clean: ->
    @dirty_static_property_names.length = 0
  
  dirtyStaticProperties: ->
    @toJSON only: @dirty_static_property_names
  
  set: (hash) ->
    super hash
  
  setProperty: (property_name, values) ->
    throw new Error 'You cannot change the ID of a model when set.' if property_name == 'id' && @get('id')
    @dirty_static_property_names.push property_name
    super property_name, values
    @save() if @storage_adapter.auto_save
  
  isPersisted: ->
    !!@get('id')
  
  isDirty: ->
    @dirty_static_property_names.length != 0
