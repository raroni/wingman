Janitor = require 'janitor'
Wingman = require '../../.'
Wingman.document = require('jsdom').jsdom()
sinon = require 'sinon'

module.exports = class extends Janitor.TestCase
  'test host addition': ->
    Wingman.request.realRequest = sinon.spy()
    class FunkySocks extends Wingman.App
      host: 'funkysocks.net'
    
    new FunkySocks el: Wingman.document.createElement('div'), view: {}
    
    Wingman.request url: '/users'
    
    @assertEqual 'http://funkysocks.net/users', Wingman.request.realRequest.args[0][0].url
  
  'test automatic data type': ->
    Wingman.request.realRequest = sinon.spy()
    Wingman.request url: '/users'
    @assertEqual 'json', Wingman.request.realRequest.args[0][0].dataType
