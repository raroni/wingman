Janitor = require 'janitor'
Wingman = require '../../.'
Wingman.document = require('jsdom').jsdom()
sinon = require 'sinon'
jsdom = require 'jsdom'

module.exports = class RequestTest extends Janitor.TestCase
  setup: ->
    Wingman.document = jsdom.jsdom()
    Wingman.window = Wingman.document.createWindow()
  
  teardown: ->
    delete Wingman.document
    delete Wingman.window
  
  'test host addition': ->
    Wingman.request.realRequest = sinon.spy()
    FunkySocks = Wingman.Application.extend
      host: 'funkysocks.net'
    
    FunkySocks.RootController = Wingman.Controller.extend()
    FunkySocks.RootView = Wingman.View.extend
      templateSource: '<div>test</div>'
    
    new FunkySocks el: Wingman.document.createElement('div')
    
    Wingman.request url: '/users'
    
    @assertEqual 'http://funkysocks.net/users', Wingman.request.realRequest.args[0][0].url
  
  'test automatic data type': ->
    Wingman.request.realRequest = sinon.spy()
    Wingman.request url: '/users'
    @assertEqual 'json', Wingman.request.realRequest.args[0][0].dataType
