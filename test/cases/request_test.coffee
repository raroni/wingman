Janitor = require 'janitor'
Wingman = require '../../.'
Wingman.document = require('jsdom').jsdom()
sinon = require 'sinon'

module.exports = class extends Janitor.TestCase
  'test host addition': ->
    Wingman.request.realRequest = sinon.spy()
    class FunkySocks extends Wingman.Application
      host: 'funkysocks.net'
    
    class FunkySocks.RootController extends Wingman.Controller
    class FunkySocks.RootView extends Wingman.View
      templateSource: -> '<div>test</div>'
    
    new FunkySocks el: Wingman.document.createElement('div')
    
    Wingman.request url: '/users'
    
    @assertEqual 'http://funkysocks.net/users', Wingman.request.realRequest.args[0][0].url
  
  'test automatic data type': ->
    Wingman.request.realRequest = sinon.spy()
    Wingman.request url: '/users'
    @assertEqual 'json', Wingman.request.realRequest.args[0][0].dataType