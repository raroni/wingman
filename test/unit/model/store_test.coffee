Janitor = require 'janitor'
Wingman = require '../../../.'
Store = require '../../../lib/wingman/model/store'

module.exports = class StoreTest extends Janitor.TestCase
  setup: ->
    class @User extends Wingman.Model
    @store = new Store
  
  'test add': ->
    user = new @User id: 1
    
    @assertEqual 0, @store.count()
    @store.add user
    @assertEqual 1, @store.count()
  
  'test add event': ->
    value_from_callback = undefined
    @store.bind 'add', (model) -> value_from_callback = model
    user = new @User id: 1
    @store.add user
    @assertEqual user, value_from_callback
  
  'test remove': ->
    Wingman.request.realRequest = (options) ->
    user = new @User id: 1
    @store.add user
    user.destroy()
    @assertEqual 0, @store.count()
  
  'test remove event': ->
    value_from_callback = undefined
    Wingman.request.realRequest = (options) ->
    user = new @User id: 1
    
    @store.bind 'remove', (model) -> value_from_callback = model
    
    @store.add user
    user.destroy()
    @assertEqual value_from_callback, user
