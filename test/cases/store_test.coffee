Janitor = require 'janitor'
Wingman = require '../../.'
WingmanObject = require '../../lib/wingman/shared/object'

class DummyCollection
  constructor: -> @values = []
  
  add: (value) ->
    @values.push value
  
  clear: ->
    @values = []
  
  isEmpty: ->
    @count() == 0
  
  count: ->
    @values.length

module.exports = class StoreTest extends Janitor.TestCase
  setup: ->
    @store = new Wingman.Store collectionClass: DummyCollection
  
  'test collection caching': ->
    class User
    @assertEqual @store.collection(User), @store.collection(User)
  
  'test clear': ->
    class User
    class Notification
    
    usersCollection = @store.collection User
    usersCollection.add 1
    usersCollection.add 2
    
    notificationsCollection = @store.collection Notification
    notificationsCollection.add 1
    
    @assertEqual 2, usersCollection.count()
    @assertEqual 1, notificationsCollection.count()
    @store.clear()
    @assertEqual 0, usersCollection.count()
    @assertEqual 0, notificationsCollection.count()
