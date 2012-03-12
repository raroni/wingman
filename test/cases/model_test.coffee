Janitor = require 'janitor'
Wingman = require '../../.'
WingmanObject = require '../../lib/wingman-client/shared/object'
sinon = require 'sinon'
RestStorage = require '../../lib/wingman-client/model/storage_adapters/rest'

uglyAssociationHack = (klass) ->
  # For now we have no better solution than this
  Wingman.Application.instance = { constructor: {} }
  Wingman.Application.instance.constructor[klass.name] = klass

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
      options.success id: 10, name: 'Ras' if options.url == '/users/10'
    
    class User extends Wingman.Model
      @storage 'rest', url: '/users'
    
    name_from_callback = undefined
    User.load 10, (user) -> name_from_callback = user.get('name')
    
    @assertEqual 'Ras', name_from_callback
  
  'test count when loading by id with rest storage': ->
    Wingman.request.realRequest = (options) ->
      options.success id: 10, name: 'Ras' if options.url == '/users/10'
      options.success id: 11, name: 'John' if options.url == '/users/11'
    
    class User extends Wingman.Model
      @storage 'rest', url: '/users'
    
    @assertEqual 0, User.count()
    User.load 10
    @assertEqual 1, User.count()
    User.load 11
    @assertEqual 2, User.count()
  
  'test load many with rest storage': ->
    Wingman.request.realRequest = (options) ->
      data = [
        { id: 1, name: 'McQueen' }
        { id: 2, name: 'Mater' }
      ]
      options.success data if options.url == '/cars' && options.type == 'GET'
    
    class Car extends Wingman.Model
      @storage 'rest', url: '/cars'
    
    array_from_callback = undefined
    Car.load (array) -> array_from_callback = array
    
    @assertEqual 2, array_from_callback.length
    @assertEqual 'McQueen', array_from_callback[0].get('name')
    @assertEqual 'Mater', array_from_callback[1].get('name')
    @assert array_from_callback[0] instanceof Car
    @assert array_from_callback[1] instanceof Car
    
  'test count when loading many with rest storage': ->
    Wingman.request.realRequest = (options) ->
      data = [
        { id: 1, name: 'McQueen' }
        { id: 2, name: 'Mater' }
      ]
      options.success data if options.url == '/cars' && options.type == 'GET'
    
    class Car extends Wingman.Model
      @storage 'rest', url: '/cars'
    
    array_from_callback = undefined
    
    @assertEqual 0, Car.count()
    Car.load (array) -> array_from_callback = array
    @assertEqual 2, Car.count()
  
  'test destroy': ->
    correct_request = undefined
    Wingman.request.realRequest = (options) ->
      correct_request = options.url == '/cars/1' && options.type == 'DELETE'
    
    class Car extends Wingman.Model
      @storage 'rest', url: '/cars'
      
    car = new Car id: 1, name: 'Toyota'
    
    value_from_callback = undefined
    car.bind 'destroy', (model) -> value_from_callback = model
    car.destroy()
    @assertEqual 'Toyota', value_from_callback.get('name')
    @assert correct_request
  
  'test scope with rest': ->
    Wingman.request.realRequest = (options) ->
      data = [
        { id: 1, name: 'McQueen', user_id: 1 }
        { id: 2, name: 'Mater', user_id: 1 }
        { id: 3, name: 'Batmobile', user_id: 2 }
      ]
      options.success data
    
    class Car extends Wingman.Model
      @storage 'rest', url: '/cars'
    
    scope = Car.scoped user_id: 1
    values_from_callback = []
    scope.bind 'add', (model) ->
      values_from_callback.push(model)
    Car.load()
    
    @assertEqual 2, scope.count()
    @assertEqual 'McQueen', values_from_callback[0].get('name')
    @assertEqual 'Mater', values_from_callback[1].get('name')
  
  'test has many association': ->
    id = 1
    Wingman.request.realRequest = (options) ->
      options.data.id = id++
      options.success options.data
    
    class User extends Wingman.Model
      @hasMany 'notifications'
    
    class Notification extends Wingman.Model
    
    uglyAssociationHack Notification
    
    user = new User()
    user.save()
    
    new Notification(user_id: 1).save() for [1..2]
    new Notification(user_id: 2).save()
    
    @assertEqual 2, user.get('notifications').count()
    delete Wingman.Application.instance
  
  'test has many association add event': ->
    id = 1
    Wingman.request.realRequest = (options) ->
      options.data.id = id++
      options.success options.data
    
    class User extends Wingman.Model
      @hasMany 'notifications'
    
    class Notification extends Wingman.Model
    
    # For now we have no better solution than 
    uglyAssociationHack Notification
    
    context = new WingmanObject
    callback_values = []
    context.observe 'user.notifications', 'add', (model) -> callback_values.push model
    
    user = new User()
    user.save()
    context.set { user }
    
    notifications = [
      new Notification(user_id: 1)
      new Notification(user_id: 2)
      new Notification(user_id: 1)
    ]
    notification.save() for notification in notifications
    
    @assertEqual 2, callback_values.length
    @assertEqual notifications[0], callback_values[0]
    @assertEqual notifications[2], callback_values[1]
    delete Wingman.Application.instance
  
  'test has many association with json export': ->
    id = 1
    Wingman.request.realRequest = (options) ->
      options.data.id = id++
      options.success options.data
    
    class User extends Wingman.Model
      @hasMany 'notifications'
    
    class Notification extends Wingman.Model
    
    uglyAssociationHack Notification
    
    user = new User()
    user.save()
    
    new Notification(user_id: 1).save() for [1..2]
    new Notification(user_id: 2).save()
    
    @assert !user.toJSON().notifications
    
    delete Wingman.Application.instance
  
  'test store add': ->
    class User extends Wingman.Model
    user = new User
    @assertEqual 0, User.store().count()
    user.set id: 1
    @assertEqual 1, User.store().count()
  
  'test exception when attempting to change id': ->
    class User extends Wingman.Model
    user = new User id: 1
    @assertThrows -> user.set id: 2
  
  teardown: ->
    delete Wingman.request.realRequest

# TODO: LOAD AND DESTROY