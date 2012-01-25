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

module.exports = class extends Janitor.TestCase
  'test automatic children instantiation': ->
    MainController = class extends ControllerWithView
    MainController.UserController = class extends ControllerWithView
    
    main_controller = new MainController
    @assert main_controller.get('user') instanceof MainController.UserController
  
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
  
  'test session sharing': ->
    MainController = class extends ControllerWithView
    MainController.UserController = class extends ControllerWithView
    MainController.UserController.NameController = class extends ControllerWithView
    MainController.UserController.NameController.FirstController = class extends ControllerWithView
    
    session = new WingmanObject
    controller = new MainController children: { options: { session} }
    @assertEqual session, controller.get('user.name.first.session')
