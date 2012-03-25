Janitor = require 'janitor'
Wingman = require '../../../.'
Store = require '../../../lib/wingman-client/model/store'

module.exports = class StoreTest extends Janitor.TestCase
  setup: ->
    class @User extends Wingman.Model # maybe this should just be a dummy object rather than a Wingman.Model to better illustrate the purpose?
    @store = new Store
  
  'test add': ->
    user = new @User id: 1
    
    @assertEqual 0, @store.count()
    @store.add user
    @assertEqual 1, @store.count()
  
  'test forEach': ->
    user1 = new @User id: 1
    user2 = new @User id: 2
    @store.add user1
    @store.add user2
    
    callbackValues = []
    @store.forEach (model) -> callbackValues.push(model)
    
    @assertEqual 2, callbackValues.length
    @assertEqual user1, callbackValues[0]
    @assertEqual user2, callbackValues[1]
    
  'test add event': ->
    valueFromCallback = undefined
    @store.bind 'add', (model) -> valueFromCallback = model
    user = new @User id: 1
    @store.add user
    @assertEqual user, valueFromCallback
  
  'test remove': ->
    Wingman.request.realRequest = (options) ->
    user = new @User id: 1
    @store.add user
    user.destroy()
    @assertEqual 0, @store.count()
  
  'test remove event': ->
    valueFromCallback = undefined
    Wingman.request.realRequest = (options) ->
    user = new @User id: 1
    
    @store.bind 'remove', (model) -> valueFromCallback = model
    
    @store.add user
    user.destroy()
    @assertEqual valueFromCallback, user
  
  'test add two models with same id': ->
    user1 = new @User id: 1, name: 'Megaman'
    user2 = new @User id: 1, name: 'Sonic'
    
    @assertEqual 0, @store.count()
    @store.add user1
    @assertEqual 1, @store.count()
    @store.add user2
    @assertEqual 1, @store.count()
    @assertEqual 'Sonic', user1.get('name')
    
  'test find': ->
    user = new @User id: 1, name: 'Ras'
    @store.add user
    @assertEqual 'Ras', @store.find(1).get('name')
