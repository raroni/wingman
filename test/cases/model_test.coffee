Janitor = require 'janitor'
Wingman = require '../../.'
WingmanObject = require '../../lib/wingman/shared/object'
HasManyAssociation = require '../../lib/wingman/model/has_many_association'
sinon = require 'sinon'
RestStorage = require '../../lib/wingman/model/storage_adapters/rest'

module.exports = class ModelTest extends Janitor.TestCase
  setup: ->
    Wingman.global = {}
  
  teardown: ->
    delete Wingman.global
    delete Wingman.request.realRequest
  
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
    @assert user.storageAdapter instanceof RestStorage
  
  'test request parameters when saving new rest model': ->
    User = class extends Wingman.Model
      @storage 'rest', url: '/users'
    
    Wingman.request.realRequest = sinon.spy()
    
    user = new User name: 'Rasmus', age: 25
    user.save()
    
    firstArgument = Wingman.request.realRequest.args[0][0]
    @assertEqual 'POST', firstArgument.type
    @assertEqual '/users', firstArgument.url
    @assertEqual 'Rasmus', firstArgument.data.name
    @assertEqual 25, firstArgument.data.age
    @assertEqual 2, Object.keys(firstArgument.data).length
    
  'test request parameters when updating existing rest model': ->
    User = class extends Wingman.Model
      @storage 'rest', url: '/users'
    
    Wingman.request.realRequest = sinon.spy()
    
    user = new User id: 1, name: 'Rasmus', age: 25
    user.clean()
    user.set name: 'Rasmus RN'
    user.save()
    
    firstArgument = Wingman.request.realRequest.args[0][0]
    @assertEqual 'PUT', firstArgument.type
    @assertEqual "/users/#{user.get('id')}", firstArgument.url
    @assertEqual 'Rasmus RN', firstArgument.data.name
    @assertEqual 1, Object.keys(firstArgument.data).length
  
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
    
    callbackCalled = false
    
    user = new User name: 'Rasmus', age: 25
    user.save
      success: ->
        callbackCalled = true
  
    @assert callbackCalled
    
  'test error callback for rest model': ->
    User = class extends Wingman.Model
      @storage 'rest', url: '/users'
    
    Wingman.request.realRequest = (options) ->
      options.error()
    
    callbackCalled = false
    
    user = new User name: 'Rasmus', age: 25
    user.save
      error: ->
        callbackCalled = true
    
    @assert callbackCalled
  
  'test auto save with local storage': ->
    User = class extends Wingman.Model
      @storage 'local', namespace: 'users'
    
    user = new User name: 'Rasmus'
    @assert !user.isDirty()
    user.set name: 'John'
    @assert !user.isDirty()
    
  'test load with local storage': ->
    Wingman.localStorage.setItem "sessions.1", JSON.stringify({ userId: 27 })
    
    class Session extends Wingman.Model
      @storage 'local', namespace: 'sessions'
    
    session = new Session id: 1, name: 'Rasmus'
    session.load()
    @assertEqual 27, session.get('userId')
    
  'test load via id without an instance with local storage': ->
    Wingman.localStorage.setItem "sessions.10", JSON.stringify({ userId: 27 })
    class Session extends Wingman.Model
      @storage 'local', namespace: 'sessions'
    
    userIdFromCallback = undefined
    Session.load 10, (session) ->
      userIdFromCallback = session.get('userId')
    
    @assertEqual 27, userIdFromCallback
    
  'test load via id without an instance with rest storage': ->
    Wingman.request.realRequest = (options) ->
      options.success id: 10, name: 'Ras' if options.url == '/users/10'
    
    class User extends Wingman.Model
      @storage 'rest', url: '/users'
    
    nameFromCallback = undefined
    User.load 10, (user) -> nameFromCallback = user.get('name')
    
    @assertEqual 'Ras', nameFromCallback
  
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
    
    arrayFromCallback = undefined
    Car.load (array) -> arrayFromCallback = array
    
    @assertEqual 2, arrayFromCallback.length
    @assertEqual 'McQueen', arrayFromCallback[0].get('name')
    @assertEqual 'Mater', arrayFromCallback[1].get('name')
    @assert arrayFromCallback[0] instanceof Car
    @assert arrayFromCallback[1] instanceof Car
    
  'test count when loading many with rest storage': ->
    Wingman.request.realRequest = (options) ->
      data = [
        { id: 1, name: 'McQueen' }
        { id: 2, name: 'Mater' }
      ]
      options.success data if options.url == '/cars' && options.type == 'GET'
    
    class Car extends Wingman.Model
      @storage 'rest', url: '/cars'
    
    arrayFromCallback = undefined
    
    @assertEqual 0, Car.count()
    Car.load (array) -> arrayFromCallback = array
    @assertEqual 2, Car.count()
  
  'test destroy': ->
    correctRequest = undefined
    Wingman.request.realRequest = (options) ->
      correctRequest = options.url == '/cars/1' && options.type == 'DELETE'
    
    class Car extends Wingman.Model
      @storage 'rest', url: '/cars'
      
    car = new Car id: 1, name: 'Toyota'
    
    valueFromCallback = undefined
    car.bind 'destroy', (model) -> valueFromCallback = model
    car.destroy()
    @assertEqual 'Toyota', valueFromCallback.get('name')
    @assert correctRequest
  
  'test scope with rest': ->
    Wingman.request.realRequest = (options) ->
      data = [
        { id: 1, name: 'McQueen', userId: 1 }
        { id: 2, name: 'Mater', userId: 1 }
        { id: 3, name: 'Batmobile', userId: 2 }
      ]
      options.success data
    
    class Car extends Wingman.Model
      @storage 'rest', url: '/cars'
    
    scope = Car.scoped userId: 1
    valuesFromCallback = []
    scope.bind 'add', (model) ->
      valuesFromCallback.push(model)
    Car.load()
    
    @assertEqual 2, scope.count()
    @assertEqual 'McQueen', valuesFromCallback[0].get('name')
    @assertEqual 'Mater', valuesFromCallback[1].get('name')
  
  'test initialization of has many association': ->
    class User extends Wingman.Model
      @hasMany 'notifications'
    
    class Wingman.global.Notification extends Wingman.Model
    
    user = new User()
    @assertEqual Wingman.global.Notification, user.get('notifications').associatedClass
  
  'test initialization of has many association with a two word name': ->
    class User extends Wingman.Model
      @hasMany 'forumTopics'
    
    class Wingman.global.ForumTopic extends Wingman.Model
    
    user = new User()
    @assertEqual Wingman.global.ForumTopic, user.get('forumTopics').associatedClass
  
  'test has many association count': ->
    id = 1
    Wingman.request.realRequest = (options) ->
      options.data.id = id++
      options.success options.data
  
    class User extends Wingman.Model
      @hasMany 'notifications'
  
    class Wingman.global.Notification extends Wingman.Model
  
    user = new User()
    user.save()
    
    new Wingman.global.Notification(userId: 1).save() for [1..2]
    new Wingman.global.Notification(userId: 2).save()
    
    @assertEqual 2, user.get('notifications').count()
  
  'test has many association add event': ->
    id = 1
    Wingman.request.realRequest = (options) ->
      options.data.id = id++
      options.success options.data
    
    class User extends Wingman.Model
      @hasMany 'notifications'
    
    class Wingman.global.Notification extends Wingman.Model
    
    context = new WingmanObject
    callbackValues = []
    context.observe 'user.notifications', 'add', (model) -> callbackValues.push model
    
    user = new User()
    user.save()
    context.set { user }
    
    notifications = [
      new Wingman.global.Notification(userId: 1)
      new Wingman.global.Notification(userId: 2)
      new Wingman.global.Notification(userId: 1)
    ]
    notification.save() for notification in notifications
    
    @assertEqual 2, callbackValues.length
    @assertEqual notifications[0], callbackValues[0]
    @assertEqual notifications[2], callbackValues[1]
  
  'test has many nested population': ->
    class User extends Wingman.Model
      @hasMany 'notifications'
    
    class Wingman.global.Notification extends Wingman.Model
    
    user = new User id: 1, name: 'Rasmus', notifications: [ { id: 1, title: 'yeah' }, { id: 2, title: 'something else' } ]
    @assertEqual 2, Wingman.global.Notification.count()
    @assertEqual 2, user.get('notifications').count()
  
  'test has many association with json export': ->
    id = 1
    Wingman.request.realRequest = (options) ->
      options.data.id = id++
      options.success options.data
    
    class User extends Wingman.Model
      @hasMany 'notifications'
    
    class Wingman.global.Notification extends Wingman.Model
    
    user = new User()
    user.save()
    
    new Wingman.global.Notification(userId: 1).save() for [1..2]
    new Wingman.global.Notification(userId: 2).save()
    
    @assert !user.toJSON().notifications
  
  'test store add': ->
    class User extends Wingman.Model
    user = new User
    @assertEqual 0, User.store().count()
    user.set id: 1
    @assertEqual 1, User.store().count()
  
  'test find': ->
    class User extends Wingman.Model
    new User id: 1, name: 'Ras'
    @assertEqual 'Ras', User.find(1).get('name')
  
  'test exception when attempting to change id': ->
    class User extends Wingman.Model
    user = new User id: 1
    @assertThrows -> user.set id: 2

# TODO: LOAD AND DESTROY
