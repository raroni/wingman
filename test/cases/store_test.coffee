WingmanObject = require '../../lib/wingman/shared/object'
Janitor = require 'janitor'
Store = require '../../lib/wingman/store'

DummyCollection = WingmanObject.extend
  initialize: -> @values = []
  add: (value) -> @values.push value
  flush: -> @values = []
  isEmpty: -> @count() == 0
  count: -> @values.length

module.exports = class StoreTest extends Janitor.TestCase
  setup: ->
    @store = Store.create collectionClass: DummyCollection
    @SomeModel = WingmanObject.extend
      id: null
      initialize: (hash) ->
        @[key] = value for key, value of hash
      
      flush: -> @trigger 'flush', @
  
  'test collection caching': ->
    @assertEqual @store.collection(@SomeModel), @store.collection(@SomeModel)
  
  'test flush': ->
    Notification = WingmanObject.extend()
    
    usersCollection = @store.collection @SomeModel
    usersCollection.add @SomeModel.create(id: 1)
    usersCollection.add @SomeModel.create(id: 2)
    
    notificationsCollection = @store.collection Notification
    notificationsCollection.add @SomeModel.create(id: 3)
    
    @assertEqual 2, usersCollection.count()
    @assertEqual 1, notificationsCollection.count()
    @store.flush()
    @assertEqual 0, usersCollection.count()
    @assertEqual 0, notificationsCollection.count()
