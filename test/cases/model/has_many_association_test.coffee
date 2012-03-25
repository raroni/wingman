Janitor = require 'janitor'
Wingman = require '../../../.'
HasManyAssociation = require '../../../lib/wingman-client/model/has_many_association'

module.exports = class HasManyAssociationTest extends Janitor.TestCase
  setup: ->
    class @User extends Wingman.Model
    class @Notification extends Wingman.Model
  
  'test count': ->
    user = new @User
    association = new HasManyAssociation user, @Notification
    user.set id: 1
    
    new @Notification id: 1, userId: 1, text: 'Hello'
    new @Notification id: 2, userId: 1, text: 'Bonsoir'
    new @Notification id: 3, userId: 2, text: 'Goddag'
    
    @assertEqual 2, association.count()
    
  'test count for association with model without an ID': ->
    user = new @User
    association = new HasManyAssociation user, @Notification
    @assertEqual 0, association.count()
  
  'test for each': ->
    user = new @User
    association = new HasManyAssociation user, @Notification
    user.set id: 1
    
    new @Notification id: 1, userId: 1, text: 'Hello'
    new @Notification id: 2, userId: 1, text: 'Bonsoir'
    new @Notification id: 3, userId: 2, text: 'Goddag'
    
    valuesFromForEachCallback = []
    association.forEach (model) ->
      valuesFromForEachCallback.push model
    
    @assertEqual 2, valuesFromForEachCallback.length
    @assertEqual 'Hello', valuesFromForEachCallback[0].get('text')
    @assertEqual 'Bonsoir', valuesFromForEachCallback[1].get('text')
  
  'test for each on model without an ID': ->
    user = new @User
    association = new HasManyAssociation user, @Notification
    
    callbackFired = false
    association.forEach -> callbackFired = true
    @assert !callbackFired
  
  'test build by hash': ->
    user = new @User id: 13
    association = new HasManyAssociation user, @Notification
    
    association.build id: 1, title: 'YO'
    
    @assertEqual 'YO', @Notification.find(1).get('title')
    @assertEqual 13, @Notification.find(1).get('userId')
  
  'test build by array': ->
    user = new @User id: 13
    association = new HasManyAssociation user, @Notification
    
    association.build [
      { id: 1, title: 'YO' },
      { id: 2, title: 'HI' }
    ]
    
    @assertEqual 'YO', @Notification.find(1).get('title')
    @assertEqual 13, @Notification.find(1).get('userId')
    @assertEqual 'HI', @Notification.find(2).get('title')
    @assertEqual 13, @Notification.find(2).get('userId')
  
  'test add event': ->
    user = new @User
    association = new HasManyAssociation user, @Notification
    user.set id: 27
    valueFromCallback = undefined
    association.bind 'add', (model) -> valueFromCallback = model
    
    notification = new @Notification id: 1, userId: 27, text: 'Hello'
    
    @assertEqual notification, valueFromCallback

  'test add event for models added prior to model getting an ID': ->
    user = new @User
    association = new HasManyAssociation user, @Notification
    notification = new @Notification id: 1, userId: 27, text: 'Hello'
    
    valueFromCallback = undefined
    association.bind 'add', (model) -> valueFromCallback = model
    
    user.set id: 27
    
    @assertEqual notification, valueFromCallback

  'test remove event': ->
    Wingman.request.realRequest = ->
    user = new @User
    association = new HasManyAssociation user, @Notification
    user.set id: 27
    valueFromCallback = undefined
    association.bind 'remove', (model) -> valueFromCallback = model
    
    notification = new @Notification id: 1, userId: 27, text: 'Hello'
    notification.destroy()
    
    @assertEqual notification, valueFromCallback

