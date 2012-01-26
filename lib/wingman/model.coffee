Wingman = require '../wingman'
WingmanObject = require './shared/object'
RestStorage = require './model/rest_storage'

module.exports = class extends WingmanObject
  @storage_types:
    'rest': RestStorage
  
  @storage: (type, options = {}) ->
    options.type = type
    @storage_options = options
  
  constructor: (hash) ->
    @dirty_static_property_names = []
    @set hash
    @setupStorage()
  
  setupStorage: ->
    storage_options = @constructor.storage_options || { type: 'rest' }
    klass = @constructor.storage_types[storage_options.type]
    throw new Error "Storage engine #{storage_options.type} not supported." unless klass
    delete storage_options.type
    @storage = new klass @, storage_options
  
  save: (options) ->
    operation = if @isPersisted() then 'update' else 'create'
    @storage[operation] options
  
  clean: ->
    @dirty_static_property_names.length = 0
  
  dirtyStaticProperties: ->
    @toJSON only: @dirty_static_property_names
  
  setProperty: (property_name, values) ->
    @dirty_static_property_names.push property_name
    super property_name, values
  
  isPersisted: ->
    !!@get('id')
