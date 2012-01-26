Janitor = require 'janitor'
Wingman = require '../../../.'
WingmanObject = require '../../../lib/wingman/shared/object'
RestStorage = require '../../../lib/wingman/model/rest_storage'
sinon = require 'sinon'

DummyUser = class extends WingmanObject
  get: (key) -> @[key]
  set: (hash) ->
    @[key] = value for key, value of hash
  dirtyStaticProperties: ->
    @dirty_static_properties

module.exports = class extends Janitor.TestCase
  'test succesful create': ->
    Wingman.request.realRequest = sinon.spy()
    
    user = new DummyUser
    user.dirty_static_properties = { name: 'Rasmus', age: 25 }
    storage = new RestStorage user, url: '/users'
    
    storage.create()
    
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
    storage = new RestStorage user, url: '/users'
    
    callback_fired = false
    storage.create success: -> callback_fired = true
    @assert callback_fired
  
  'test succesful update': ->
    Wingman.request.realRequest = sinon.spy()
  
    user = new DummyUser
    user.set id: 1
    user.dirty_static_properties = { name: 'Rasmus', age: 25 }
    storage = new RestStorage user, url: '/users'
    storage.update()
  
    first_argument = Wingman.request.realRequest.args[0][0]
    @assertEqual 'PUT', first_argument.type
    @assertEqual "/users/1", first_argument.url
    @assertEqual 'Rasmus', first_argument.data.name
    @assertEqual 25, first_argument.data.age
    @assertEqual 2, Object.keys(first_argument.data).length
  
  'test success callback after successful update': ->
    Wingman.request.realRequest = (options) ->
      options.success()
    
    user = new DummyUser
    storage = new RestStorage user, url: '/users'
    
    callback_fired = false
    storage.update success: -> callback_fired = true
    @assert callback_fired
