Janitor = require 'janitor'
Wingman = require '../../../.'
HasManyAssociation = require '../../../lib/wingman/model/has_many_association'

module.exports = class HasManyAssociationTest extends Janitor.TestCase
  setup: ->
    class @User extends Wingman.Model
    class @Notification extends Wingman.Model
  
  'test count': ->
    user = new @User
    association = new HasManyAssociation user, @Notification
    user.set id: 1
    
    new @Notification id: 1, user_id: 1, text: 'Hello'
    new @Notification id: 2, user_id: 1, text: 'Bonsoir'
    new @Notification id: 3, user_id: 2, text: 'Goddag'
    
    @assertEqual 2, association.count()
    
  'test count for association with model without an ID': ->
    user = new @User
    association = new HasManyAssociation user, @Notification
    @assertEqual 0, association.count()
  
  'test for each': ->
    user = new @User
    association = new HasManyAssociation user, @Notification
    user.set id: 1
    
    new @Notification id: 1, user_id: 1, text: 'Hello'
    new @Notification id: 2, user_id: 1, text: 'Bonsoir'
    new @Notification id: 3, user_id: 2, text: 'Goddag'
    
    values_from_foreach_callback = []
    association.forEach (model) ->
      values_from_foreach_callback.push model
    
    @assertEqual 2, values_from_foreach_callback.length
    @assertEqual 'Hello', values_from_foreach_callback[0].get('text')
    @assertEqual 'Bonsoir', values_from_foreach_callback[1].get('text')
  
  'test for each on model without an ID': ->
    user = new @User
    association = new HasManyAssociation user, @Notification
    
    callback_fired = false
    association.forEach -> callback_fired = true
    @assert !callback_fired
  
  'test add event': ->
    user = new @User
    association = new HasManyAssociation user, @Notification
    user.set id: 27
    value_from_callback = undefined
    association.bind 'add', (model) -> value_from_callback = model
    
    notification = new @Notification id: 1, user_id: 27, text: 'Hello'
    
    @assertEqual notification, value_from_callback
  
  'test remove event': ->
    Wingman.request.realRequest = ->
    user = new @User
    association = new HasManyAssociation user, @Notification
    user.set id: 27
    value_from_callback = undefined
    association.bind 'remove', (model) -> value_from_callback = model
    
    notification = new @Notification id: 1, user_id: 27, text: 'Hello'
    notification.destroy()
    
    @assertEqual notification, value_from_callback
