Janitor = require 'janitor'
Wingman = require '../../.'
jsdom = require 'jsdom'

DummyView = Wingman.View.extend
  templateSource: '<div>test</div>'

ControllerWithView = Wingman.Controller.extend
  initialize: (options = {}) ->
    options.view = DummyView.create parent: { el: Wingman.document.createElement('div') }
    @_super options

module.exports = class ControllerTest extends Janitor.TestCase
  setup: ->
    Wingman.document = jsdom.jsdom()
  
  teardown: ->
    delete Wingman.document
  
  'test ready callback': ->
    callbackFired = false
    DummyController = ControllerWithView.extend
      ready: ->
        callbackFired = true
      
    DummyView = Wingman.View.extend
      templateSource: '<div>test</div>'
      
    dummyView = DummyView.create parent: { el: Wingman.document.createElement('div') }
    dummyController = DummyController.create view: dummyView
    
    @assert callbackFired
  
  'test property dependencies': ->
    callbackFired = false
    
    MainView = Wingman.View.extend()
    MainController = Wingman.Controller.extend
      someMethod: -> 'my value'
    
    MainController.addPropertyDependencies
      someMethod: 'state.test'
    
    state = Wingman.Object.extend(test: null).create()
    view = MainView.create { state }
    controller = MainController.create view
    
    controller.observe 'someMethod', -> callbackFired = true
    
    state.test = 'something'
    
    @assert callbackFired
  
  'test bindings': ->
    numberFromSave = false
    
    MainView = Wingman.View.extend()
    MainController = Wingman.Controller.extend
      bindings:
        playerClicked: 'save'
      
      save: (number) ->
        numberFromSave = number
    
    view = MainView.create()
    controller = MainController.create view
    view.trigger 'playerClicked', 123
    @assertEqual 123, numberFromSave
  
  'test methods depending on app property not being called upon initialization': ->
    called = false
    MainController = Wingman.Controller.extend
      something: -> called = true
    
    MainController.addPropertyDependencies
      something: 'app.loggedIn'
    
    view = MainController.create app: {}
    @assert !called
