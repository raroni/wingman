Janitor = require 'janitor'
Wingman = require '../../../.'
Collection = require '../../../lib/wingman/store/collection'

module.exports = class CollectionTest extends Janitor.TestCase
  setup: ->
    @User = Wingman.Model.extend name: null # maybe this should just be a dummy object rather than a Wingman.Model to better illustrate the purpose?
    @collection = Collection.create()
  
  'test add': ->
    user = @User.create id: 1
    
    @assertEqual 0, @collection.count()
    @collection.add user
    @assertEqual 1, @collection.count()
  
  'test forEach': ->
    user1 = @User.create id: 1
    user2 = @User.create id: 2
    @collection.add user1
    @collection.add user2
    
    callbackValues = []
    @collection.forEach (model) -> callbackValues.push(model)
    
    @assertEqual 2, callbackValues.length
    @assertEqual user1, callbackValues[0]
    @assertEqual user2, callbackValues[1]
    
  'test add event': ->
    valueFromCallback = undefined
    @collection.bind 'add', (model) -> valueFromCallback = model
    user = @User.create id: 1
    @collection.add user
    @assertEqual user, valueFromCallback
  
  'test flushing model': ->
    Wingman.request.realRequest = (options) ->
    user = @User.create id: 1
    @collection.add user
    user.flush()
    @assertEqual 0, @collection.count()
  
  'test remove event': ->
    valueFromCallback = undefined
    Wingman.request.realRequest = (options) ->
    user = @User.create id: 1
    
    @collection.bind 'remove', (model) -> valueFromCallback = model
    
    @collection.add user
    user.destroy()
    @assertEqual valueFromCallback, user
  
  'test add two models with same id': ->
    user1 = @User.create id: 1, name: 'Megaman'
    user2 = @User.create id: 1, name: 'Sonic'
    
    @assertEqual 0, @collection.count()
    @collection.add user1
    @assertEqual 1, @collection.count()
    @collection.add user2
    @assertEqual 1, @collection.count()
    @assertEqual 'Sonic', user1.name
    
  'test find': ->
    user = @User.create id: 1, name: 'Ras'
    @collection.add user
    @assertEqual 'Ras', @collection.find(1).name
  
  'test flush': ->
    user1 = @User.create id: 1
    user2 = @User.create id: 2
    @collection.add user1
    @collection.add user2
    
    @assertEqual 2, @collection.count()
    @collection.flush()
    @assertEqual 0, @collection.count()
