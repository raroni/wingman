Wingman = require '../wingman'
WingmanObject = require './shared/object'
StorageAdapter = require './model/storage_adapter'
Store = require './model/store'
Scope = require './model/scope'

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
  
  @loadOne: (id, callback) ->
    @storageAdapter().load id, success: (hash) =>
      model = new @ hash
      @store().add model
      callback model if callback

  @loadMany: (callback) ->
    @storageAdapter().load success: (array) =>
      models = []
      for model_data in array
        model = new @ model_data
        @store().add model
        models.push model
      callback models if callback
  
  @scoped: (params) ->
    new Scope @store(), params
  
  constructor: (properties, options) ->
    @storage_adapter = @constructor.storageAdapter()
    @dirty_static_property_names = []
    @set properties
  
  save: (options = {}) ->
    operation = if @isPersisted() then 'update' else 'create'
    @storage_adapter[operation] @,
      success: (data) =>
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
    @storage_adapter.load @get('id'), success: (hash) => @set hash
  
  clean: ->
    @dirty_static_property_names.length = 0
  
  dirtyStaticProperties: ->
    @toJSON only: @dirty_static_property_names
  
  set: (hash) ->
    super hash
  
  setProperty: (property_name, values) ->
    @dirty_static_property_names.push property_name
    super property_name, values
    @save() if @storage_adapter.auto_save
  
  isPersisted: ->
    !!@get('id')
  
  isDirty: ->
    @dirty_static_property_names.length != 0
