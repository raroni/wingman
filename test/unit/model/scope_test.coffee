Janitor = require 'janitor'
Wingman = require '../../../.'
Scope = require '../../../lib/wingman/model/scope'
Store = require '../../../lib/wingman/model/store'

module.exports = class StoreTest extends Janitor.TestCase
  setup: ->
    class @Notification extends Wingman.Model
  
  'test add': ->
    scope = new Scope @Notification.store(), user_id: 1
    
    notifications = [
      new @Notification id: 1, user_id: 1, text: 'Goddag'
      new @Notification id: 2, user_id: 1, text: 'Bonsoir'
      new @Notification id: 3, user_id: 2, text: 'Goddag'
    ]
    
    @assertEqual 2, scope.count()
    @assertEqual 'Goddag', scope.find(1).get('text')
    @assertEqual 'Bonsoir', scope.find(2).get('text')
  
  'test add event': ->
    scope = new Scope @Notification.store(), user_id: 1
    values_from_callback = []
    scope.bind 'add', (model) -> values_from_callback.push(model)
  
    new @Notification id: 1, user_id: 1, text: 'Goddag'
    new @Notification id: 2, user_id: 1, text: 'Bonsoir'
    new @Notification id: 3, user_id: 2, text: 'Goddag'
    
    @assertEqual 'Goddag', values_from_callback[0].get('text')
    @assertEqual 'Bonsoir', values_from_callback[1].get('text')
  
  'test remove': ->
    Wingman.request.realRequest = (options) ->
    scope = new Scope @Notification.store(), user_id: 1
    
    notification = new @Notification id: 1, user_id: 1, text: 'Goddag'
    new @Notification id: 2, user_id: 1, text: 'Bonsoir'
    new @Notification id: 3, user_id: 2, text: 'Goddag'
    
    notification.destroy()
    @assertEqual 1, scope.count()
  
  'test remove event': ->
    Wingman.request.realRequest = (options) ->
    scope = new Scope @Notification.store(), user_id: 1
    value_from_callback = undefined
    scope.bind 'remove', (model) -> value_from_callback = model
    
    notification = new @Notification id: 1, user_id: 1, text: 'Goddag'
    new @Notification id: 2, user_id: 1, text: 'Bonsoir'
    new @Notification id: 3, user_id: 2, text: 'Goddag'
    
    notification.destroy()
    @assertEqual value_from_callback, notification

  'test deferred change': ->
    scope = new Scope @Notification.store(), user_id: 1
    
    notification = new @Notification id: 1, user_id: 1, text: 'Goddag'
    new @Notification id: 2, user_id: 1, text: 'Bonsoir'
    new @Notification id: 3, user_id: 2, text: 'Goddag'
    
    notification.set user_id: 2
    @assertEqual 1, scope.count()
    @assertThrows -> scope.find(1)
