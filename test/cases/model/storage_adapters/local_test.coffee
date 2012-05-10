Janitor = require 'janitor'
Wingman = require '../../../../.'
Wingman.localStorage = require 'localStorage'
LocalStorage = require '../../../../lib/wingman/model/storage_adapters/local'

User = Wingman.Object.extend
  id: null
  name: null
  age: null
  initialize: (hash) ->
    @[key] = value for key, value of hash

module.exports = class LocalStorageTest extends Janitor.TestCase
  'test create': ->
    user = User.create name: 'Rasmus', age: 25
    storage = LocalStorage.create namespace: 'users'
    storage.create user
    
    data = JSON.parse Wingman.localStorage.getItem("users.#{user.id}")
    
    @assert user.id
    @assertEqual 'Rasmus', data.name
    @assertEqual 25, data.age
  
  'test load': ->
    Wingman.localStorage.setItem "users.1", JSON.stringify({ name: 'Rasmus', age: 25 })
    
    user = User.create()
    user.id = 1
    storage = LocalStorage.create namespace: 'users'
    storage.load user.id, success: (hash) => user.set hash
    
    @assertEqual 'Rasmus', user.name
    @assertEqual 25, user.age
  
  'test update': ->
    Wingman.localStorage.setItem "users.1", JSON.stringify({ name: 'Rasmus', age: 25 })
    
    user = User.create id: 1
    storage = LocalStorage.create namespace: 'users'
    storage.load user.id, success: (hash) => user.set hash
    
    user.name = 'Razdaman'
    storage.update user
    
    data = JSON.parse Wingman.localStorage.getItem("users.#{user.id}")
    @assertEqual 'Razdaman', data.name
  
  'test updating when manually setting id': ->
    user = User.create id: 1, name: 'RAS'
    storage = LocalStorage.create namespace: 'users'
    storage.update user
    data = JSON.parse Wingman.localStorage.getItem("users.1")
    @assertEqual 'RAS', data.name
  
  'test updating already exisiting entry': ->
    user = User.create id: 1, name: 'RAS', age: 25
    storage = LocalStorage.create namespace: 'users'
    storage.update user
    
    user = User.create()
    user.set id: 1, name: 'RAS'
    storage.update user
    
    ageFromCallback = undefined
    storage.load user.id, success: (hash) => ageFromCallback = hash.age
    
    @assertEqual 25, ageFromCallback
  
  'test delete': ->
    user = User.create name: 'Rasmus', age: 25
    storage = LocalStorage.create namespace: 'users'
    storage.create user
    storage.delete user.id
    
    data = Wingman.localStorage.getItem("users.#{user.id}")
    @assert !data
  
  teardown: ->
    Wingman.localStorage.clear()
