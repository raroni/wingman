Janitor = require 'janitor'
Wingman = require '../../.'

User = class extends Wingman.Model

module.exports = class extends Janitor.TestCase
  'test setting attributes via constructor': ->
    user = new User name: 'Rasmus', age: 25
    
    @assert_equal 'Rasmus', user.get('name')
    @assert_equal 25, user.get('age')
