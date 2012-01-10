Janitor = require 'janitor'
Wingman = require '../../.'
sinon = require 'sinon'

User = class extends Wingman.Model
  url: '/users'

module.exports = class extends Janitor.TestCase
  'test setting attributes via constructor': ->
    user = new User name: 'Rasmus', age: 25
    
    @assertEqual 'Rasmus', user.get('name')
    @assertEqual 25, user.get('age')
  
  'test persistense check': ->
    user = new User name: 'Rasmus', id: 1
    @assert user.persisted()
    
    user = new User name: 'Rasmus'
    @assert !user.persisted()
  
  'test saveURL with app host': ->
    Wingman.Model.host = 'http://wingmanjs.com'
    user = new User
    @assertEqual 'http://wingmanjs.com/users', user.saveURL()
    delete Wingman.Model.host
  
  'test request parameters when saving new model': ->
    Wingman.request = sinon.spy()
    
    user = new User name: 'Rasmus', age: 25
    user.save()
    
    first_argument = Wingman.request.args[0][0]
    @assertEqual 'POST', first_argument.type
    @assertEqual '/users', first_argument.url
    @assertEqual 'Rasmus', first_argument.data.name
    @assertEqual 25, first_argument.data.age
    @assertEqual 2, Object.keys(first_argument.data).length
    
  'test request parameters when updating existing model': ->
    Wingman.request = sinon.spy()
    
    user = new User id: 1, name: 'Rasmus', age: 25
    user.clean()
    user.set name: 'Rasmus RN'
    user.save()
    
    first_argument = Wingman.request.args[0][0]
    @assertEqual 'PUT', first_argument.type
    @assertEqual "/users/#{user.get('id')}", first_argument.url
    @assertEqual 'Rasmus RN', first_argument.data.name
    @assertEqual 1, Object.keys(first_argument.data).length

  'test setting id after succesfully persisting to server': ->
    Wingman.request = (options) ->
      options.success id: 123
    
    user = new User name: 'Rasmus', age: 25
    user.save()
    
    @assert 123, user.get('id')

    # TODO: LOAD AND DESTROY
