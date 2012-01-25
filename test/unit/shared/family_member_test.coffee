Janitor = require 'janitor'
WingmanObject = require '../../../lib/wingman/shared/object'
FamilyMember = require '../../../lib/wingman/shared/family_member'

class DummyController extends WingmanObject
  @include FamilyMember
  
  constructor: (options) ->
    @parent = options.parent
    @createChildren 'Controller', child_source: options?.child_source

SimpleController = class extends DummyController
SimpleController.UserController = class extends DummyController
SimpleController.MailController = class extends DummyController

NestedController = class extends DummyController
NestedController.LoggedInController = class extends DummyController
NestedController.LoggedInController.WelcomeController = class extends DummyController
NestedController.LoginController = class extends DummyController

module.exports = class extends Janitor.TestCase
  'test simple child instantiation': ->
    controller = new SimpleController parent: {}
    @assert controller.get('user') instanceof SimpleController.UserController
    @assert controller.get('mail') instanceof SimpleController.MailController
  
  'test nested child instantiation': ->
    controller = new NestedController parent: {}
    @assert controller.get('logged_in') instanceof NestedController.LoggedInController
    @assert controller.get('login') instanceof NestedController.LoginController
    @assert controller.get('logged_in.welcome') instanceof NestedController.LoggedInController.WelcomeController
  
  'test nested path': ->
    controller = new NestedController parent: {}
    welcome_controller = controller.get('logged_in.welcome')
    @assertEqual 'logged_in.welcome', welcome_controller.path()

  'test child source': ->
    DummyApp = class
    DummyApp.UserController = class extends DummyController
    DummyApp.MainController = class extends DummyController
    DummyApp.RootController = class extends DummyController
    
    app = new DummyApp
    controller = new DummyApp.RootController parent: app, child_source: app
    
    @assert controller.get('user') instanceof DummyApp.UserController
    @assert controller.get('main') instanceof DummyApp.MainController
    @assertEqual undefined, controller.get('root')
