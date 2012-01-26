Wingman = require '../wingman'
WingmanObject = require './shared/object'
RestStorage = require './model/rest_storage'
LocalStorage = require './model/local_storage'

module.exports = class extends WingmanObject
  @storage_types:
    'rest': RestStorage
    'local': LocalStorage
  
  @storage: (type, options = {}) ->
    options.type = type
    @storage_options = options
  
  constructor: (properties, options) ->
    @storage = @buildStorage()
    @dirty_static_property_names = []
    @set properties
  
  buildStorage: ->
    storage_options = @constructor.storage_options || { type: 'rest' }
    klass = @constructor.storage_types[storage_options.type]
    throw new Error "Storage engine #{storage_options.type} not supported." unless klass
    delete storage_options.type
    new klass @, storage_options
  
  save: (options = {}) ->
    operation = if @isPersisted() then 'update' else 'create'
    @storage[operation]
      success: =>
        @clean()
        options.success?()
      error: -> options.error?()
  
  toParam: ->
    @get 'id'
  
  clean: ->
    @dirty_static_property_names.length = 0
  
  dirtyStaticProperties: ->
    @toJSON only: @dirty_static_property_names
  
  set: (hash) ->
    super hash
  
  setProperty: (property_name, values) ->
    @dirty_static_property_names.push property_name
    super property_name, values
    @save() if @storage.auto_save
  
  isPersisted: ->
    !!@get('id')
  
  isDirty: ->
    @dirty_static_property_names.length != 0
