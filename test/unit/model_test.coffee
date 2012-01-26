Janitor = require 'janitor'
Wingman = require '../../.'
sinon = require 'sinon'
RestStorage = require '../../lib/wingman/model/rest_storage'

module.exports = class extends Janitor.TestCase
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
    @assert user.storage instanceof RestStorage
  
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
    
    user = new User { name: 'Rasmus' }
    @assert !user.isDirty()
    user.set name: 'John'
    @assert !user.isDirty()
    
  'test model load with local storage': ->
    Wingman.localStorage.setItem "sessions.1", JSON.stringify({ user_id: 1 })
    
    User = class extends Wingman.Model
      @storage 'local', namespace: 'users'

    user = new User { name: 'Rasmus' }
    @assert !user.isDirty()
    user.set name: 'John'
    @assert !user.isDirty()

# TODO: LOAD AND DESTROY
