Janitor = require 'janitor'
Wingman = require '../../.'
WingmanObject = require '../../lib/wingman/shared/object'
Wingman.document = require('jsdom').jsdom()

class DummyView extends Wingman.View
  templateSource: -> '<div>test</div>'

class ControllerWithView extends Wingman.Controller
  constructor: (options = {}) ->
    options.view = new DummyView parent: { el: Wingman.document.createElement('div') }
    super options

module.exports = class ControllerTest extends Janitor.TestCase
  'test ready callback': ->
    callbackFired = false
    DummyController = class extends ControllerWithView
      ready: ->
        callbackFired = true
      
    DummyView = class extends Wingman.View
      templateSource: -> '<div>test</div>'
      
    dummyView = new DummyView parent: { el: Wingman.document.createElement('div') }
    dummyController = new DummyController view: dummyView
    
    @assert callbackFired
  
  'test property dependencies': ->
    callbackFired = false
    
    class MainView extends Wingman.View
    class MainController extends Wingman.Controller
      @propertyDependencies
        someMethod: 'app.test'
      
      someMethod: ->
        callbackFired = true
    
    app = new WingmanObject
    view = new MainView { app }
    controller = new MainController view
    
    app.set test: 'something'
    
    @assert callbackFired
  
  'test bindings': ->
    numberFromSave = false
    
    class MainView extends Wingman.View
    class MainController extends Wingman.Controller
      bindings:
        playerClicked: 'save'
      
      save: (number) ->
        numberFromSave = number
    
    view = new MainView
    controller = new MainController view
    view.trigger 'playerClicked', 123
    @assertEqual 123, numberFromSave
