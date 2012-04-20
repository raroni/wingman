Collection = require './store/collection'

module.exports = class Store
  constructor: (@options) ->
    @collections = {}
    @collectionClass = @options?.collectionClass || Collection
  
  collection: (klass) ->
    @collections[klass] || @createCollection klass
  
  createCollection: (klass) ->
    @collections[klass] = new @collectionClass klass
  
  clear: ->
    collection.clear() for klass, collection of @collections
