RestStorage = require './storage_adapters/rest'
LocalStorage = require './storage_adapters/local'

module.exports =
  storage_types:
    'rest': RestStorage
    'local': LocalStorage
  
  storage: (type, options = {}) ->
    throw new Error "Storage engine #{type} not supported." unless @storageAdapterTypeSupported(type)
    options.type = type
    @storage_adapter_options = options
  
  storageAdapterTypeSupported: (type) ->
    !!@storage_types[type]
  
  storageAdapter: ->
    @storage_adapter ||= @buildStorageAdapter()
  
  buildStorageAdapter: ->
    @storage_adapter_options ||= { type: 'rest' }
    klass = @storage_types[@storage_adapter_options.type]
    options = {}
    options[key] = value for key, value of @storage_adapter_options when key != 'type'
    new klass options
  
  load: (id, callback) ->
    @storageAdapter().load id, success: (hash) =>
      model = new @ hash
      callback model
