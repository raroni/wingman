Janitor = require 'janitor'
Wingman = require '../../../.'
Store = require '../../../lib/wingman/model/store'

class User extends Wingman.Model

module.exports = class StoreTest extends Janitor.TestCase
  'test add': ->
    store = new Store()
    user = new User
    
    @assertEqual 0, store.count()
    store.add user
    @assertEqual 1, store.count()
