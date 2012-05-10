RestStorage = require './storage_adapters/rest'
LocalStorage = require './storage_adapters/local'

module.exports =
  storageTypes:
    'rest': RestStorage
    'local': LocalStorage

  storageAdapter: ->
    if !@hasOwnProperty '_storageAdapter'
      @_storageAdapter = @buildStorageAdapter()
    else
    @_storageAdapter
  
  storageAdapterTypeSupported: (type) ->
    !!@storageTypes[type]
  
  buildStorageAdapter: ->
    @storage ||= { type: 'rest' }
    throw new Error "Storage engine #{type} not supported." unless @storageAdapterTypeSupported @storage.type
    klass = @storageTypes[@storage.type]
    options = {}
    options[key] = value for key, value of @storage when key != 'type'
    new klass options
