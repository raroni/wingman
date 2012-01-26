Janitor = require 'janitor'
Wingman = require '../../../.'
Wingman.localStorage = require 'localStorage'
WingmanObject = require '../../../lib/wingman/shared/object'
LocalStorage = require '../../../lib/wingman/model/local_storage'

User = class extends WingmanObject

module.exports = class extends Janitor.TestCase
  'test create': ->
    user = new User
    user.set name: 'Rasmus', age: 25
    storage = new LocalStorage user, namespace: 'users'
    storage.create()
    
    data = JSON.parse Wingman.localStorage.getItem("users.#{user.get('id')}")
    
    @assert user.get('id')
    @assertEqual 'Rasmus', data.name
    @assertEqual 25, data.age

  'test load': ->
    Wingman.localStorage.setItem "users.1", JSON.stringify({ name: 'Rasmus', age: 25 })
    
    user = new User
    user.set id: 1
    storage = new LocalStorage user, namespace: 'users'
    storage.load()
    
    @assertEqual 'Rasmus', user.get('name')
    @assertEqual 25, user.get('age')

  'test update': ->
    Wingman.localStorage.setItem "users.1", JSON.stringify({ name: 'Rasmus', age: 25 })

    user = new User
    user.set id: 1
    storage = new LocalStorage user, namespace: 'users'
    storage.load()

    user.set name: 'Razdaman'
    storage.update()
    
    data = JSON.parse Wingman.localStorage.getItem("users.#{user.get('id')}")
    @assertEqual 'Razdaman', data.name
  
  'test updating when manually setting id': ->
    user = new User
    user.set id: 1, name: 'RAS'
    storage = new LocalStorage user, namespace: 'users'
    storage.update()
    data = JSON.parse Wingman.localStorage.getItem("users.1")
    @assertEqual 'RAS', data.name
  
  teardown: ->
    Wingman.localStorage.clear()
