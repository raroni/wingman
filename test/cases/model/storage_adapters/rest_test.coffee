Janitor = require 'janitor'
Wingman = require '../../../../.'
RestStorage = require '../../../../lib/wingman/model/storage_adapters/rest'
sinon = require 'sinon'

DummyUser = Wingman.Object.extend
  dirtyStaticProperties: ->
    @_dirtyStaticProperties

module.exports = class RestTest extends Janitor.TestCase
  teardown: -> delete Wingman.request.realRequest
  
  'test succesful create': ->
    Wingman.request.realRequest = sinon.spy()
    
    user = new DummyUser
    user._dirtyStaticProperties = { name: 'Rasmus', age: 25 }
    storage = new RestStorage url: '/users'
    
    storage.create user
    
    firstArgument = Wingman.request.realRequest.args[0][0]
    @assertEqual 'POST', firstArgument.type
    @assertEqual '/users', firstArgument.url
    @assertEqual 'Rasmus', firstArgument.data.name
    @assertEqual 25, firstArgument.data.age
    @assertEqual 2, Object.keys(firstArgument.data).length

  'test success callback after successful create': ->
    Wingman.request.realRequest = (options) ->
      options.success()
    
    user = new DummyUser
    storage = new RestStorage url: '/users'
    
    callbackFired = false
    storage.create user, success: -> callbackFired = true
    @assert callbackFired
  
  'test succesful update': ->
    Wingman.request.realRequest = (options) =>
      @assertEqual 'PUT', options.type
      @assertEqual "/users/1", options.url
      @assertEqual 'Rasmus', options.data.name
      @assertEqual 25, options.data.age
      @assertEqual 2, Object.keys(options.data).length
      successHash = { email: 'secret@gmail.com' }
      successHash[key] = value for key, value of options.data
      options.success successHash
  
    user = new DummyUser
    user.set id: 1
    user._dirtyStaticProperties = { name: 'Rasmus', age: 25 }
    storage = new RestStorage url: '/users'
    
    hashFromCallback = undefined
    storage.update user, success: (hash) -> hashFromCallback = hash
    
    @assertEqual 3, Object.keys(hashFromCallback).length
    @assertEqual 'secret@gmail.com', hashFromCallback.email
  
  'test success callback after successful update': ->
    Wingman.request.realRequest = (options) ->
      options.success()
    
    user = new DummyUser
    storage = new RestStorage url: '/users'
    
    callbackFired = false
    storage.update user, success: -> callbackFired = true
    @assert callbackFired
  
  'test load by id': ->
    Wingman.request.realRequest = (options) ->
      options.success name: 'Rasmus' if options.url == '/users/21' && options.type == 'GET'
    
    storage = new RestStorage url: '/users'
    nameFromCallback = undefined
    storage.load 21, success: (hash) ->
      nameFromCallback = hash.name
    
    @assertEqual 'Rasmus', nameFromCallback
  
  'test load all': ->
    car1 = { name: 'McQueen' }
    car2 = { name: 'Mater' }
    Wingman.request.realRequest = (options) ->
      data = [car1, car2]
      options.success data if options.url == '/cars' && options.type == 'GET'
    
    storage = new RestStorage url: '/cars'
    arrayFromCallback = undefined
    storage.load success: (array) ->
      arrayFromCallback = array
    
    @assertEqual 2, arrayFromCallback.length
    @assertContains arrayFromCallback, car1
    @assertContains arrayFromCallback, car2
  
  'test delete': ->
    correctRequest = undefined
    Wingman.request.realRequest = (options) ->
      correctRequest = options.url == '/cars/1' && options.type == 'DELETE'
    
    storage = new RestStorage url: '/cars'
    storage.delete 1
    
    @assert correctRequest
