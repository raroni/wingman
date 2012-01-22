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
    
  'test activation/deactivation of siblings': ->
    DummyController = class extends Wingman.Controller
    DummyView = class extends Wingman.View
      templateSource: -> '<div>test</div>'
      
    DummyController.UserController = class extends Wingman.Controller
    DummyController.UserView = class
      templateSource: -> '<div>test</div>'
      
    DummyController.MailController = class extends Wingman.Controller
    DummyController.MailView = class
      templateSource: -> '<div>test</div>'
    
    dummy_view = new DummyView parent_el: Wingman.document.createElement 'div'
    dummy_controller = new DummyController view: dummy_view
    
    dummy_controller.controllers.mail.activate()
    @assert dummy_controller.controllers.mail.isActive()
    @assert !dummy_controller.controllers.user.isActive()
    
    dummy_controller.controllers.user.activate()
    @assert dummy_controller.controllers.user.isActive()
    @assert !dummy_controller.controllers.mail.isActive()

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
