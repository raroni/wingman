Wingman = require '../wingman'
WingmanObject = require './shared/object'
RestStorage = require './model/rest_storage'
LocalStorage = require './model/local_storage'

module.exports = class extends WingmanObject
  @storage_types:
    'rest': RestStorage
    'local': LocalStorage
  
  @storage: (type, options = {}) ->
    throw new Error "Storage engine #{type} not supported." unless @storageAdapterTypeSupported(type)
    options.type = type
    @storage_adapter_options = options
  
  @storageAdapterTypeSupported: (type) ->
    !!@storage_types[type]
  
  @storageAdapter: ->
    @storage_adapter ||= @buildStorageAdapter()
  
  @buildStorageAdapter: ->
    @storage_adapter_options ||= { type: 'rest' }
    klass = @storage_types[@storage_adapter_options.type]
    options = {}
    options[key] = value for key, value of @storage_adapter_options when key != 'type'
    new klass options
  
  constructor: (properties, options) ->
    @storage_adapter = @constructor.storageAdapter()
    @dirty_static_property_names = []
    @set properties
  
  save: (options = {}) ->
    operation = if @isPersisted() then 'update' else 'create'
    @storage_adapter[operation] @,
      success: =>
        @clean()
        options.success?()
      error: -> options.error?()
  
  toParam: ->
    @get 'id'
  
  load: ->
    @storage_adapter.load @, success: (hash) => @set hash
  
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
