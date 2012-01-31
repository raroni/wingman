Wingman = require '../wingman'
WingmanObject = require './shared/object'
StorageAdapter = require './model/storage_adapter'

module.exports = class extends WingmanObject
  @extend StorageAdapter
  
  @load: (id, callback) ->
    @storageAdapter().load id, success: (hash) =>
      model = new @ hash
      callback model
  
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
