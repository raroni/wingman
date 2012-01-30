Janitor = require 'janitor'
Wingman = require '../../.'
sinon = require 'sinon'
RestStorage = require '../../lib/wingman/model/rest_storage'

module.exports = class ModelTest extends Janitor.TestCase
  'test setting attributes via constructor': ->
    User = class extends Wingman.Model
    user = new User name: 'Rasmus', age: 25
    
    @assertEqual 'Rasmus', user.get('name')
    @assertEqual 25, user.get('age')
  
  'test persistense check': ->
    User = class extends Wingman.Model
    user = new User name: 'Rasmus', id: 1
    @assert user.isPersisted()
    
    user = new User name: 'Rasmus'
    @assert !user.isPersisted()
    
  'test setting default storage adapter': ->
    User = class extends Wingman.Model
    user = new User
    @assert user.storage_adapter instanceof RestStorage
  
  'test request parameters when saving new rest model': ->
    User = class extends Wingman.Model
      @storage 'rest', url: '/users'
    
    Wingman.request.realRequest = sinon.spy()
    
    user = new User name: 'Rasmus', age: 25
    user.save()
    
    first_argument = Wingman.request.realRequest.args[0][0]
    @assertEqual 'POST', first_argument.type
    @assertEqual '/users', first_argument.url
    @assertEqual 'Rasmus', first_argument.data.name
    @assertEqual 25, first_argument.data.age
    @assertEqual 2, Object.keys(first_argument.data).length
    
  'test request parameters when updating existing rest model': ->
    User = class extends Wingman.Model
      @storage 'rest', url: '/users'
    
    Wingman.request.realRequest = sinon.spy()
    
    user = new User id: 1, name: 'Rasmus', age: 25
    user.clean()
    user.set name: 'Rasmus RN'
    user.save()
    
    first_argument = Wingman.request.realRequest.args[0][0]
    @assertEqual 'PUT', first_argument.type
    @assertEqual "/users/#{user.get('id')}", first_argument.url
    @assertEqual 'Rasmus RN', first_argument.data.name
    @assertEqual 1, Object.keys(first_argument.data).length
  
  'test setting properties returned by server after succesfull rest save': ->
    User = class extends Wingman.Model
      @storage 'rest', url: '/users'
    
    Wingman.request.realRequest = (options) ->
      options.success id: 123, gender: 'm'
    
    user = new User name: 'Rasmus', age: 25
    user.save()
    
    @assertEqual 123, user.get('id')
    @assertEqual 'm', user.get('gender')
  
  'test success callback with rest model': ->
    User = class extends Wingman.Model
      @storage 'rest', url: '/users'
    
    Wingman.request.realRequest = (options) ->
      options.success id: 1
    
    callback_called = false
    
    user = new User name: 'Rasmus', age: 25
    user.save
      success: ->
        callback_called = true
  
    @assert callback_called
    
  'test error callback for rest model': ->
    User = class extends Wingman.Model
      @storage 'rest', url: '/users'
    
    Wingman.request.realRequest = (options) ->
      options.error()
    
    callback_called = false
    
    user = new User name: 'Rasmus', age: 25
    user.save
      error: ->
        callback_called = true
    
    @assert callback_called
  
  'test auto save with local storage': ->
    User = class extends Wingman.Model
      @storage 'local', namespace: 'users'
    
    user = new User name: 'Rasmus'
    @assert !user.isDirty()
    user.set name: 'John'
    @assert !user.isDirty()
    
  'test load with local storage': ->
    Wingman.localStorage.setItem "sessions.1", JSON.stringify({ user_id: 27 })
    
    class Session extends Wingman.Model
      @storage 'local', namespace: 'sessions'

    session = new Session id: 1, name: 'Rasmus'
    session.load()
    @assertEqual 27, session.get('user_id')
    
  'test load via id without an instance with local storage': ->
    Wingman.localStorage.setItem "sessions.10", JSON.stringify({ user_id: 27 })
    class Session extends Wingman.Model
      @storage 'local', namespace: 'sessions'
    
    user_id_from_callback = undefined
    Session.load 10, (session) ->
      user_id_from_callback = session.get('user_id')
    
    @assertEqual 27, user_id_from_callback
    
  'test load via id without an instance with rest storage': ->
    Wingman.request.realRequest = (options) ->
      options.success name: 'Ras' if options.url == '/users/10'
    
    class User extends Wingman.Model
      @storage 'rest', url: '/users'

    name_from_callback = undefined
    User.load 10, (user) -> name_from_callback = user.get('name')

    @assertEqual 'Ras', name_from_callback
      
# TODO: LOAD AND DESTROY
