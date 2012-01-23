Janitor = require 'janitor'
Wingman = require '../../../lib/wingman'
ChildInstantiator = require '../../../lib/wingman/shared/child_instantiator'
ObjectTree = require '../../../lib/wingman/object_tree'

dummy_app =
  deactivateDescendantsExceptChild: ->

class DummyView extends Wingman.View
  templateSource: -> '<div>test</div>'

class ControllerWithView extends Wingman.Controller
  constructor: (options = {}) ->
    options.view = new DummyView parent: { el: Wingman.document.createElement('div') }
    super options

module.exports = class extends Janitor.TestCase
  simpleController: ->
    MainController = class extends ControllerWithView
    MainController.UserController = class extends ControllerWithView
    MainController.MailController = class extends ControllerWithView
    new MainController
  
  nestedController: ->
    MainController = class extends ControllerWithView
    MainController.LoggedInController = class extends ControllerWithView
    MainController.LoggedInController.WelcomeController = class extends ControllerWithView
    MainController.LoginController = class extends ControllerWithView
    new MainController
  
  'test deactivation of children': ->
    main_controller = @simpleController()
    main_controller.deactivateDescendantsExceptChild 'user'
    @assertEqual undefined, main_controller.get('user').is_active
    @assertEqual false, main_controller.get('mail').is_active
  
  'test nested deactivation of children': ->
    main_controller = @nestedController()
    
    main_controller.get('logged_in').deactivateDescendantsExceptChild 'welcome'
    @assertEqual undefined, main_controller.get('logged_in').is_active
    @assertEqual false, main_controller.get('login').is_active
  
  'test nested path': ->
    main_controller = @nestedController()
    welcome_controller = main_controller.get('logged_in.welcome')
    @assertEqual 'logged_in.welcome', welcome_controller.path()
  