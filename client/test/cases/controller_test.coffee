Janitor = require 'janitor'
Wingman = require '../../.'
WingmanObject = require '../../lib/wingman-client/shared/object'
Wingman.document = require('jsdom').jsdom()

class DummyView extends Wingman.View
  templateSource: -> '<div>test</div>'

class ControllerWithView extends Wingman.Controller
  constructor: (options = {}) ->
    options.view = new DummyView parent: { el: Wingman.document.createElement('div') }
    super options

module.exports = class ControllerTest extends Janitor.TestCase
  'test ready callback': ->
    callback_fired = false
    DummyController = class extends ControllerWithView
      ready: ->
        callback_fired = true
      
    DummyView = class extends Wingman.View
      templateSource: -> '<div>test</div>'
      
    dummy_view = new DummyView parent: { el: Wingman.document.createElement('div') }
    dummy_controller = new DummyController view: dummy_view
    
    @assert callback_fired
  
  'test property dependencies': ->
    callback_fired = false
    
    class MainView extends Wingman.View
    class MainController extends Wingman.Controller
      @propertyDependencies
        someMethod: 'shared.test'
      
      someMethod: ->
        callback_fired = true
    
    shared = new WingmanObject
    view = new MainView { shared }
    controller = new MainController view
    
    shared.set test: 'something'
    
    @assert callback_fired
