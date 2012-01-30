Janitor = require 'janitor'
Wingman = require '../../../../.'
WingmanObject = require '../../../../lib/wingman/shared/object'
RestStorage = require '../../../../lib/wingman/model/storage_adapters/rest'
sinon = require 'sinon'

class DummyUser extends WingmanObject
  get: (key) -> @[key]
  set: (hash) ->
    @[key] = value for key, value of hash
  dirtyStaticProperties: ->
    @dirty_static_properties

module.exports = class RestStorageTest extends Janitor.TestCase
  teardown: -> delete Wingman.request.realRequest
  
  'test succesful create': ->
    Wingman.request.realRequest = sinon.spy()
    
    user = new DummyUser
    user.dirty_static_properties = { name: 'Rasmus', age: 25 }
    storage = new RestStorage url: '/users'
    
    storage.create user
    
    first_argument = Wingman.request.realRequest.args[0][0]
    @assertEqual 'POST', first_argument.type
    @assertEqual '/users', first_argument.url
    @assertEqual 'Rasmus', first_argument.data.name
    @assertEqual 25, first_argument.data.age
    @assertEqual 2, Object.keys(first_argument.data).length

  'test success callback after successful create': ->
    Wingman.request.realRequest = (options) ->
      options.success()
    
    user = new DummyUser
    storage = new RestStorage url: '/users'
    
    callback_fired = false
    storage.create user, success: -> callback_fired = true
    @assert callback_fired
  
  'test succesful update': ->
    Wingman.request.realRequest = (options) =>
      @assertEqual 'PUT', options.type
      @assertEqual "/users/1", options.url
      @assertEqual 'Rasmus', options.data.name
      @assertEqual 25, options.data.age
      @assertEqual 2, Object.keys(options.data).length
      success_hash = { email: 'secret@gmail.com' }
      success_hash[key] = value for key, value of options.data
      options.success success_hash
  
    user = new DummyUser
    user.set id: 1
    user.dirty_static_properties = { name: 'Rasmus', age: 25 }
    storage = new RestStorage url: '/users'
    
    hash_from_callback = undefined
    storage.update user, success: (hash) -> hash_from_callback = hash
    
    @assertEqual 3, Object.keys(hash_from_callback).length
    @assertEqual 'secret@gmail.com', hash_from_callback.email
  
  'test success callback after successful update': ->
    Wingman.request.realRequest = (options) ->
      options.success()
    
    user = new DummyUser
    storage = new RestStorage url: '/users'
    
    callback_fired = false
    storage.update user, success: -> callback_fired = true
    @assert callback_fired
  
  'test load': ->
    Wingman.request.realRequest = (options) ->
      options.success name: 'Rasmus' if options.url == '/users/21' && options.type == 'GET'
    
    storage = new RestStorage url: '/users'
    name_from_callback = undefined
    storage.load 21, success: (hash) ->
      name_from_callback = hash.name
    
    @assertEqual 'Rasmus', name_from_callback
