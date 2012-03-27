RestStorage = require './storage_adapters/rest'
LocalStorage = require './storage_adapters/local'

module.exports =
  storageTypes:
    'rest': RestStorage
    'local': LocalStorage
  
  storage: (type, options = {}) ->
    throw new Error "Storage engine #{type} not supported." unless @storageAdapterTypeSupported(type)
    options.type = type
    @storageAdapterOptions = options
  
  storageAdapterTypeSupported: (type) ->
    !!@storageTypes[type]
  
  storageAdapter: ->
    @_storageAdapter ||= @buildStorageAdapter()
  
  buildStorageAdapter: ->
    @storageAdapterOptions ||= { type: 'rest' }
    klass = @storageTypes[@storageAdapterOptions.type]
    options = {}
    options[key] = value for key, value of @storageAdapterOptions when key != 'type'
    new klass options
