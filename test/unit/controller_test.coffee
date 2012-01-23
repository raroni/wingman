Janitor = require 'janitor'
Wingman = require '../../.'
Wingman.document = require('jsdom').jsdom()

class DummyView extends Wingman.View
  templateSource: -> '<div>test</div>'

class ControllerWithView extends Wingman.Controller
  constructor: (options = {}) ->
    options.view = new DummyView parent: { el: Wingman.document.createElement('div') }
    super options

module.exports = class extends Janitor.TestCase
  'test automatic children instantiation': ->
    MainController = class extends ControllerWithView
    MainController.UserController = class extends ControllerWithView
    
    main_controller = new MainController
    @assert main_controller.get('user') instanceof MainController.UserController
  
  'test activation': ->
    dummy_app =
      deactivateDescendantsExceptChild: ->
    
    parent_controller = new ControllerWithView parent: dummy_app
    dummy_controller = new ControllerWithView parent: parent_controller
    
    dummy_controller.activate()
    @assertEqual true, dummy_controller.is_active
    @assertEqual true, dummy_controller.view.is_active
  
  'test deactivation': ->
    DummyController = class extends Wingman.Controller
    DummyView = class extends Wingman.View
      templateSource: -> '<div>test</div>'
  
    parent_controller = new ControllerWithView
    dummy_controller = new ControllerWithView parent: parent_controller
  
    dummy_controller.activate()
    dummy_controller.deactivate()
    @assertEqual false, dummy_controller.is_active
    @assertEqual false, dummy_controller.view.is_active
  
  'test activation/deactivation of siblings': ->
    MainController = class extends ControllerWithView
    MainController.UserController = class extends ControllerWithView
    MainController.MailController = class extends ControllerWithView
    
    dummy_app =
      deactivateDescendantsExceptChild: ->
    dummy_controller = new MainController parent: dummy_app
    
    dummy_controller.get('mail').activate()
    @assert dummy_controller.get('mail').is_active
    @assert !dummy_controller.get('user').is_active
    
    dummy_controller.get('user').activate()
    @assert dummy_controller.get('user').is_active
    @assert !dummy_controller.get('mail').is_active
  
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
