Janitor = require 'janitor'
Wingman = require '../../../../.'
Wingman.localStorage = require 'localStorage'
WingmanObject = require '../../../../lib/wingman/shared/object'
LocalStorage = require '../../../../lib/wingman/model/storage_adapters/local'

User = class extends WingmanObject

module.exports = class LocalStorageTest extends Janitor.TestCase
  'test create': ->
    user = new User
    user.set name: 'Rasmus', age: 25
    storage = new LocalStorage namespace: 'users'
    storage.create user
    
    data = JSON.parse Wingman.localStorage.getItem("users.#{user.get('id')}")
    
    @assert user.get('id')
    @assertEqual 'Rasmus', data.name
    @assertEqual 25, data.age

  'test load': ->
    Wingman.localStorage.setItem "users.1", JSON.stringify({ name: 'Rasmus', age: 25 })
    
    user = new User
    user.set id: 1
    storage = new LocalStorage namespace: 'users'
    storage.load user.get('id'), success: (hash) => user.set hash
    
    @assertEqual 'Rasmus', user.get('name')
    @assertEqual 25, user.get('age')
  
  'test update': ->
    Wingman.localStorage.setItem "users.1", JSON.stringify({ name: 'Rasmus', age: 25 })
    
    user = new User
    user.set id: 1
    storage = new LocalStorage namespace: 'users'
    storage.load user.get('id'), success: (hash) => user.set hash
    
    user.set name: 'Razdaman'
    storage.update user
    
    data = JSON.parse Wingman.localStorage.getItem("users.#{user.get('id')}")
    @assertEqual 'Razdaman', data.name
  
  'test updating when manually setting id': ->
    user = new User
    user.set id: 1, name: 'RAS'
    storage = new LocalStorage namespace: 'users'
    storage.update user
    data = JSON.parse Wingman.localStorage.getItem("users.1")
    @assertEqual 'RAS', data.name
  
  'test updating already exisiting entry': ->
    user = new User
    user.set id: 1, name: 'RAS', age: 25
    storage = new LocalStorage namespace: 'users'
    storage.update user
    
    user = new User
    user.set id: 1, name: 'RAS'
    storage.update user
    
    ageFromCallback = undefined
    storage.load user.get('id'), success: (hash) => ageFromCallback = hash.age
    
    @assertEqual 25, ageFromCallback
  
  'test delete': ->
    user = new User
    user.set name: 'Rasmus', age: 25
    storage = new LocalStorage namespace: 'users'
    storage.create user
    storage.delete user.get('id')
    
    data = Wingman.localStorage.getItem("users.#{user.get('id')}")
    @assert !data
  
  teardown: ->
    Wingman.localStorage.clear()
