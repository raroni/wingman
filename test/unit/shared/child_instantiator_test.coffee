Janitor = require 'janitor'
Module = require '../../../lib/wingman/shared/module'
ChildInstantiator = require '../../../lib/wingman/shared/child_instantiator'

DummyController = class extends Module
  @include ChildInstantiator
  
  constructor: (@options) ->
    @parent = @options?.parent
    @setupChildControllers()
  
  deactivate: ->
    @is_active = false

module.exports = class extends Janitor.TestCase
  simpleController: ->
    MainController = class extends DummyController
    MainController.UserController = class extends DummyController
    MainController.UserView = class
    MainController.MailController = class extends DummyController
    MainController.MailView = class
    new MainController
  
  nestedController: ->
    MainController = class extends DummyController
    MainController.LoggedInController = class extends DummyController
    MainController.LoggedInView = class
    MainController.LoggedInController.WelcomeController = class extends DummyController
    MainController.LoggedInController.WelcomeView = class
    MainController.LoginController = class extends DummyController
    MainController.LoginView = class
    new MainController
  
  'test find child controllers': ->
    main_controller = @simpleController()
    @child_controllers = main_controller.findChildControllers()
    @assertEqual 2, @child_controllers.length
    @assertContains @child_controllers, main_controller.constructor.UserController
    @assertContains @child_controllers, main_controller.constructor.MailController
  
  'test single controller setup': ->
    main_controller = @simpleController()
    main_controller.constructor.UserController._name = 'user' # this is normally done by #findChildControllers
    user_controller = main_controller.buildController main_controller.constructor.UserController
    @assert user_controller instanceof main_controller.constructor.UserController
    @assertEqual main_controller, user_controller.options.parent
    @assert user_controller.options.view instanceof main_controller.constructor.UserView
  
  'test setup all controllers': ->
    main_controller = @simpleController()
    @assertEqual 2, Object.keys(main_controller.controllers).length
    @assert main_controller.controllers.mail instanceof main_controller.constructor.MailController
    @assert main_controller.controllers.user instanceof main_controller.constructor.UserController
  
  'test deactivation of children': ->
    main_controller = @simpleController()
    main_controller.deactivateDescendantsExceptChild 'user'
    @assertEqual undefined, main_controller.controllers.user.is_active
    @assertEqual false, main_controller.controllers.mail.is_active
  
  'test nested deactivation of children': ->
    main_controller = @nestedController()
    
    main_controller.controllers.logged_in.deactivateDescendantsExceptChild 'welcome'
    @assertEqual undefined, main_controller.controllers.logged_in.is_active
    @assertEqual false, main_controller.controllers.login.is_active
  
  'test nested path': ->
    main_controller = @nestedController()
    welcome_controller = main_controller.controllers.logged_in.controllers.welcome
    @assertEqual 'logged_in.welcome', welcome_controller.path()
