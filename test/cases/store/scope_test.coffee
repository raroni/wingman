Janitor = require 'janitor'
Wingman = require '../../../.'
Scope = require '../../../lib/wingman/store/scope'

module.exports = class ScopeTest extends Janitor.TestCase
  setup: ->
    @Notification = Wingman.Model.extend()
    @Notification.belongsTo 'user'
  
  teardown: ->
    Wingman.store().flush()
  
  'test add': ->
    scope = new Scope @Notification.collection(), userId: 1
    
    new @Notification id: 1, userId: 1, text: 'Goddag'
    new @Notification id: 2, userId: 1, text: 'Bonsoir'
    new @Notification id: 3, userId: 2, text: 'Goddag'
    
    @assertEqual 2, scope.count()
    @assertEqual 'Goddag', scope.find(1).get('text')
    @assertEqual 'Bonsoir', scope.find(2).get('text')
  
  'test add event': ->
    scope = new Scope @Notification.collection(), userId: 1
    valuesFromCallback = []
    scope.bind 'add', (model) -> valuesFromCallback.push(model)
  
    new @Notification id: 1, userId: 1, text: 'Goddag'
    new @Notification id: 2, userId: 1, text: 'Bonsoir'
    new @Notification id: 3, userId: 2, text: 'Goddag'
    
    @assertEqual 'Goddag', valuesFromCallback[0].get('text')
    @assertEqual 'Bonsoir', valuesFromCallback[1].get('text')
  
  'test for each': ->
    scope = new Scope @Notification.collection(), userId: 1
  
    notifications = [
      new @Notification id: 1, userId: 1, text: 'Goddag'
      new @Notification id: 3, userId: 2, text: 'Goddag'
    ]
    
    callbackValues = []
    scope.forEach (model) => callbackValues.push(model)
    @assertEqual 1, callbackValues.length
    @assertEqual notifications[0], callbackValues[0]
  
  'test remove': ->
    Wingman.request.realRequest = (options) ->
    scope = new Scope @Notification.collection(), userId: 1
    
    notification = new @Notification id: 1, userId: 1, text: 'Goddag'
    new @Notification id: 2, userId: 1, text: 'Bonsoir'
    new @Notification id: 3, userId: 2, text: 'Goddag'
    
    notification.destroy()
    @assertEqual 1, scope.count()
  
  'test remove event': ->
    Wingman.request.realRequest = (options) ->
    scope = new Scope @Notification.collection(), userId: 1
    valueFromCallback = undefined
    scope.bind 'remove', (model) -> valueFromCallback = model
    
    notification = new @Notification id: 1, userId: 1, text: 'Goddag'
    new @Notification id: 2, userId: 1, text: 'Bonsoir'
    new @Notification id: 3, userId: 2, text: 'Goddag'
    
    notification.destroy()
    @assertEqual valueFromCallback, notification
  
  'test deferred change': ->
    scope = new Scope @Notification.collection(), userId: 1
    
    notification = new @Notification id: 1, userId: 1, text: 'Goddag'
    new @Notification id: 2, userId: 1, text: 'Bonsoir'
    new @Notification id: 3, userId: 2, text: 'Goddag'
    
    notification.userId = 2
    @assertEqual 1, scope.count()
    @assertThrows -> scope.find(1)
  
  'test creating scope when theres already matches in the collection': ->
    new @Notification id: 1, userId: 1, text: 'Goddag'
    new @Notification id: 2, userId: 2, text: 'Bonsoir'
    
    scope = new Scope @Notification.collection(), userId: 1
    @assertEqual 1, scope.count()
    @assertEqual 'Goddag', scope.find(1).get('text')
