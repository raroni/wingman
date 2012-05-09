Janitor = require 'janitor'
Wingman = require '../../.'
HasManyAssociation = require '../../lib/wingman/model/has_many_association'
sinon = require 'sinon'
RestStorage = require '../../lib/wingman/model/storage_adapters/rest'

module.exports = class ModelTest extends Janitor.TestCase
  setup: ->
    Wingman.global = {}
  
  teardown: ->
    Wingman.store().flush()
    delete Wingman.global
    delete Wingman.request.realRequest
  
  'test persistense check': ->
    User = Wingman.Model.extend()
    
    user = User.create name: 'Rasmus', id: 1
    @assert user.isPersisted()
    
    user = User.create name: 'Rasmus'
    @assert !user.isPersisted()
    
  'test setting default storage adapter': ->
    User = Wingman.Model.extend()
    user = User.create()
    @assert user.storageAdapter instanceof RestStorage
  
  'test dirty properties': ->
    User = Wingman.Model.extend name: null, age: null
   
    user = User.create name: 'Rasmus', age: 25
    
    dirty = user.dirtyStaticProperties()
    
    @assertEqual 2, Object.keys(dirty).length
    @assertEqual 'Rasmus', dirty.name
    @assertEqual 25, dirty.age
    
    user.clean()
    user.name = 'John'
    dirty = user.dirtyStaticProperties()
    
    @assertEqual 1, Object.keys(dirty).length
    @assertEqual 'John', dirty.name
   
   
  
  'test request parameters when saving new rest model': ->
    User = Wingman.Model.extend name: null, age: null
    User.storage =
      type: 'rest'
      url: '/users'
    
    User.storageAdapter()
    
    Wingman.request.realRequest = sinon.spy()
    
    user = User.create name: 'Rasmus', age: 25
    user.save()
    
    firstArgument = Wingman.request.realRequest.args[0][0]
    @assertEqual 'POST', firstArgument.type
    @assertEqual '/users', firstArgument.url
    @assertEqual 'Rasmus', firstArgument.data.name
    @assertEqual 25, firstArgument.data.age
    @assertEqual 2, Object.keys(firstArgument.data).length
  
  'test request parameters when updating existing rest model': ->
    User = Wingman.Model.extend name: null, age: null
    User.storage =
      type: 'rest'
      url: '/users'
    
    Wingman.request.realRequest = sinon.spy()
    
    user = User.create id: 1, name: 'Rasmus', age: 25
    user.clean()
    user.name = 'Rasmus RN'
    user.save()
    
    firstArgument = Wingman.request.realRequest.args[0][0]
    @assertEqual 'PUT', firstArgument.type
    @assertEqual "/users/#{user.get('id')}", firstArgument.url
    @assertEqual 'Rasmus RN', firstArgument.data.name
    @assertEqual 1, Object.keys(firstArgument.data).length
  
  'test setting properties returned by server after succesfull rest save': ->
    User = Wingman.Model.extend name: null, age: null
    User.storage =
      type: 'rest'
      url: '/users'
    
    Wingman.request.realRequest = (options) ->
      options.success id: 123, gender: 'm'
    
    user = User.create name: 'Rasmus', age: 25
    user.save()
    
    @assertEqual 123, user.id
    @assertEqual 'm', user.gender
  
  'test success callback with rest model': ->
    User = Wingman.Model.extend name: null, age: null
    User.storage =
      type: 'rest'
      url: '/users'
    
    Wingman.request.realRequest = (options) ->
      options.success id: 1
    
    callbackCalled = false
    
    user = User.create name: 'Rasmus', age: 25
    user.save
      success: ->
        callbackCalled = true
  
    @assert callbackCalled
    
  'test error callback for rest model': ->
    User = Wingman.Model.extend name: null, age: null
    User.storage =
      type: 'rest'
      url: '/users'
    
    Wingman.request.realRequest = (options) ->
      options.error()
    
    callbackCalled = false
    
    user = User.create name: 'Rasmus', age: 25
    user.save
      error: ->
        callbackCalled = true
    
    @assert callbackCalled
  
  'test auto save with local storage': ->
    User = Wingman.Model.extend { name: null },
      storage:
        type: 'local'
        namespace: 'users'
    
    user = User.create name: 'Rasmus'
    @assert !user.isDirty()
    user.set name: 'John'
    @assert !user.isDirty()
    
  'test load with local storage': ->
    Wingman.localStorage.setItem "sessions.1", JSON.stringify({ userId: 27 })
    
    Session = Wingman.Model.extend { name: null, id: null, userId: null },
      storage:
        type: 'local'
        namespace: 'sessions'
    
    session = Session.create id: 1, name: 'Rasmus'
    session.load()
    @assertEqual 27, session.userId
    
  'test load via id without an instance with local storage': ->
    Wingman.localStorage.setItem "sessions.10", JSON.stringify({ userId: 27 })
    
    Session = Wingman.Model.extend {},
      storage:
        type: 'local'
        namespace: 'sessions'
    
    userIdFromCallback = undefined
    Session.load 10, (session) ->
      userIdFromCallback = session.userId
    
    @assertEqual 27, userIdFromCallback
    
  'test load via id without an instance with rest storage': ->
    Wingman.request.realRequest = (options) ->
      options.success id: 10, name: 'Ras' if options.url == '/users/10'
    
    User = Wingman.Model.extend {},
      storage:
        type: 'rest'
        url: '/users'
    
    nameFromCallback = undefined
    User.load 10, (user) -> nameFromCallback = user.get('name')
    
    @assertEqual 'Ras', nameFromCallback
  
  'test count when loading by id with rest storage': ->
    Wingman.request.realRequest = (options) ->
      options.success id: 10, name: 'Ras' if options.url == '/users/10'
      options.success id: 11, name: 'John' if options.url == '/users/11'
    
    User = Wingman.Model.extend {},
      storage:
        type: 'rest'
        url: '/users'
    
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
    
    Car = Wingman.Model.extend {},
      storage:
        type: 'rest'
        url: '/cars'
    
    arrayFromCallback = undefined
    Car.load (array) -> arrayFromCallback = array
    
    @assertEqual 2, arrayFromCallback.length
    @assertEqual 'McQueen', arrayFromCallback[0].name
    @assertEqual 'Mater', arrayFromCallback[1].name
    @assert arrayFromCallback[0] instanceof Car
    @assert arrayFromCallback[1] instanceof Car
    
  'test count when loading many with rest storage': ->
    Wingman.request.realRequest = (options) ->
      data = [
        { id: 1, name: 'McQueen' }
        { id: 2, name: 'Mater' }
      ]
      options.success data if options.url == '/cars' && options.type == 'GET'
    
    Car = Wingman.Model.extend {},
      storage:
        type: 'rest'
        url: '/cars'
    
    arrayFromCallback = undefined
    
    @assertEqual 0, Car.count()
    Car.load (array) -> arrayFromCallback = array
    @assertEqual 2, Car.count()
  
  'test destroy': ->
    correctRequest = undefined
    Wingman.request.realRequest = (options) ->
      correctRequest = options.url == '/cars/1' && options.type == 'DELETE'
    
    Car = Wingman.Model.extend {},
      storage:
        type: 'rest'
        url: '/cars'
      
    car = Car.create id: 1, name: 'Toyota'
    
    callbackValues = []
    car.bind 'destroy', (model) -> callbackValues.push model
    car.bind 'flush', (model) -> callbackValues.push model
    
    car.destroy()
    
    @assertEqual callbackValues.length, 2
    @assertEqual 'Toyota', callbackValues[0].get('name')
    @assertEqual callbackValues[0], callbackValues[1]
    @assert correctRequest
  
  'test scope with rest': ->
    Wingman.request.realRequest = (options) ->
      data = [
        { id: 1, name: 'McQueen', userId: 1 }
        { id: 2, name: 'Mater', userId: 1 }
        { id: 3, name: 'Batmobile', userId: 2 }
      ]
      options.success data
    
    Car = Wingman.Model.extend {},
      storage: 
        type: 'rest'
        url: '/cars'
    
    scope = Car.scoped userId: 1
    valuesFromCallback = []
    scope.bind 'add', (model) -> valuesFromCallback.push(model)
    Car.load()
    
    @assertEqual 2, scope.count()
    @assertEqual 'McQueen', valuesFromCallback[0].get('name')
    @assertEqual 'Mater', valuesFromCallback[1].get('name')
  
  'test initialization of has many association': ->
    User = Wingman.Model.extend()
    User.hasMany 'notifications'
    
    Wingman.global.Notification = Wingman.Model.extend()
    
    user = User.create()
    @assertEqual Wingman.global.Notification, user.notifications.associatedClass
  
  'test initialization of has many association with a two word name': ->
    User = Wingman.Model.extend()
    User.hasMany 'forumTopics'
    
    Wingman.global.ForumTopic = Wingman.Model.extend()
    
    user = User.create()
    @assertEqual Wingman.global.ForumTopic, user.forumTopics.associatedClass
  
  'test has many association count': ->
    id = 1
    Wingman.request.realRequest = (options) ->
      options.data.id = id++
      options.success options.data
    
    Wingman.global.User = User = Wingman.Model.extend()
    User.hasMany 'notifications'
    
    Wingman.global.Notification = Notification = Wingman.Model.extend()
    Notification.belongsTo 'user'
    
    user = User.create()
    user.save()
    
    Notification.create(userId: 1).save() for [1..2]
    Notification.create(userId: 2).save()
    
    @assertEqual 2, user.notifications.count()
  
  'test has many association add event': ->
    id = 1
    Wingman.request.realRequest = (options) ->
      options.data.id = id++
      options.success options.data
    
    Wingman.global.User = User = Wingman.Model.extend()
    User.hasMany 'notifications'
    
    Wingman.global.Notification = Notification = Wingman.Model.extend()
    Notification.belongsTo 'user'
    
    context = Wingman.Object.extend(user: null).create()
    callbackValues = []
    context.observe 'user.notifications', 'add', (model) -> callbackValues.push model
    
    user = User.create()
    user.save()
    context.user = user
    
    notifications = [
      Notification.create(userId: 1)
      Notification.create(userId: 2)
      Notification.create(userId: 1)
    ]
    notification.save() for notification in notifications
    
    @assertEqual 2, callbackValues.length
    @assertEqual notifications[0], callbackValues[0]
    @assertEqual notifications[2], callbackValues[1]
  
  'test has many nested population': ->
    Wingman.global.User = User = Wingman.Model.extend()
    User.hasMany 'notifications'
    
    Wingman.global.Notification = Notification = Wingman.Model.extend()
    Notification.belongsTo 'user'
    
    user = User.create id: 1, name: 'Rasmus', notifications: [ { id: 1, title: 'yeah' }, { id: 2, title: 'something else' } ]
    @assertEqual 2, Notification.count()
    @assertEqual 2, user.notifications.count()
  
  'test has many association with json export': ->
    id = 1
    Wingman.request.realRequest = (options) ->
      options.data.id = id++
      options.success options.data
    
    Wingman.global.User = User = Wingman.Model.extend()
    User.hasMany 'notifications'

    Wingman.global.Notification = Notification = Wingman.Model.extend()
    Notification.belongsTo 'user'
    
    user = User.create()
    user.save()
    
    Notification.create(userId: 1).save() for [1..2]
    Notification.create(userId: 2).save()
    
    @assert !user.toJSON().notifications
  
  'test store add': ->
    User = Wingman.Model.extend()
    user = User.create()
    @assertEqual 0, User.collection().count()
    user.id = 1
    @assertEqual 1, User.collection().count()
  
  'test find': ->
    User = Wingman.Model.extend name: 'Ras'
    user = User.create id: 1, name: 'Ras'
    @assertEqual 'Ras', User.find(1).name
  
  'test exception when attempting to change id': ->
    User = Wingman.Model.extend()
    user = User.create id: 1
    @assertThrows -> user.id = 2
  
  'test flush': ->
    User = Wingman.Model.extend()
    user = User.create id: 1
    callbackFired = false
    user.bind 'flush', -> callbackFired = true
    user.flush()
    @assert callbackFired

# TODO: LOAD AND DESTROY
