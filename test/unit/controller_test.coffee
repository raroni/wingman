Janitor = require 'janitor'
Wingman = require '../../.'
Wingman.document = require('jsdom').jsdom()

module.exports = class extends Janitor.TestCase
  'test automatic children instantiation': ->
    Wingman.View.template_sources = {
      'user': '<div>stubbing the source</div>'
    }
    
    MainController = class extends Wingman.Controller
    MainView = class extends Wingman.View
      templateSource: -> '<div>test</div>'
        
    MainController.UserController = class extends Wingman.Controller
    MainController.UserView = class extends Wingman.View
    
    root_el = Wingman.document.createElement 'div'
    view = new MainView parent_el: root_el
    controller = new MainController {view}
    
    @assert root_el.innerHTML.match('stubbing the source')
  
  'test activation': ->
    DummyController = class extends Wingman.Controller
    DummyView = class extends Wingman.View
      templateSource: -> '<div>test</div>'
    
    dummy_view = new DummyView parent_el: Wingman.document.createElement 'div'
    parent_controller = new DummyController view: dummy_view
    dummy_controller = new DummyController view: dummy_view, parent: parent_controller
    
    dummy_controller.activate()
    @assertEqual true, dummy_controller.is_active
    @assertEqual true, dummy_controller.view.is_active
  
  'test deactivation': ->
    DummyController = class extends Wingman.Controller
    DummyView = class extends Wingman.View
      templateSource: -> '<div>test</div>'

    dummy_view = new DummyView parent_el: Wingman.document.createElement 'div'
    parent_controller = new DummyController view: dummy_view
    dummy_controller = new DummyController view: dummy_view, parent: parent_controller

    dummy_controller.activate()
    dummy_controller.deactivate()
    @assertEqual false, dummy_controller.is_active
    @assertEqual false, dummy_controller.view.is_active
  
  'test activation/deactivation of siblings': ->
    DummyController = class extends Wingman.Controller
    DummyView = class extends Wingman.View
      templateSource: -> '<div>test</div>'
      
    DummyController.UserController = class extends Wingman.Controller
    DummyController.UserView = class extends Wingman.View
      templateSource: -> '<div>test</div>'
      
    DummyController.MailController = class extends Wingman.Controller
    DummyController.MailView = class extends Wingman.View
      templateSource: -> '<div>test</div>'
    
    dummy_view = new DummyView parent_el: Wingman.document.createElement 'div'
    dummy_controller = new DummyController view: dummy_view
    
    dummy_controller.controllers.mail.activate()
    @assert dummy_controller.controllers.mail.is_active
    @assert !dummy_controller.controllers.user.is_active
    
    dummy_controller.controllers.user.activate()
    @assert dummy_controller.controllers.user.is_active
    @assert !dummy_controller.controllers.mail.is_active

  'test ready callback': ->
    callback_fired = false
    DummyController = class extends Wingman.Controller
      ready: ->
        callback_fired = true
      
    DummyView = class extends Wingman.View
      templateSource: -> '<div>test</div>'
      
    dummy_view = new DummyView parent_el: Wingman.document.createElement 'div'
    dummy_controller = new DummyController view: dummy_view
    
    @assert callback_fired
