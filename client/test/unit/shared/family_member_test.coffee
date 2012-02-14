Janitor = require 'janitor'
WingmanObject = require '../../../lib/wingman-client/shared/object'
FamilyMember = require '../../../lib/wingman-client/shared/family_member'

class DummyController extends WingmanObject
  @include FamilyMember
  
  constructor: (options) ->
    @parent = options.parent
    @familize 'controller', options.children

SimpleController = class extends DummyController
SimpleController.UserController = class extends DummyController
SimpleController.MailController = class extends DummyController

NestedController = class extends DummyController
NestedController.LoggedInController = class extends DummyController
NestedController.LoggedInController.WelcomeController = class extends DummyController
NestedController.LoginController = class extends DummyController

module.exports = class FamilyMemberTest extends Janitor.TestCase
  'test simple child instantiation': ->
    controller = new SimpleController parent: {}
    @assert controller.get('user_controller') instanceof SimpleController.UserController
    @assert controller.get('mail_controller') instanceof SimpleController.MailController
  
  'test nested child instantiation': ->
    controller = new NestedController parent: {}
    @assert controller.get('logged_in_controller') instanceof NestedController.LoggedInController
    @assert controller.get('login_controller') instanceof NestedController.LoginController
    @assert controller.get('logged_in_controller.welcome_controller') instanceof NestedController.LoggedInController.WelcomeController
  
  'test nested path': ->
    controller = new NestedController parent: {}
    welcome_controller = controller.get('logged_in_controller.welcome_controller')
    @assertEqual 'logged_in_controller.welcome_controller', welcome_controller.path()
  
  'test child source': ->
    DummyApp = class
    DummyApp.UserController = class extends DummyController
    DummyApp.MainController = class extends DummyController
    DummyApp.RootController = class extends DummyController
    
    app = new DummyApp
    controller = new DummyApp.RootController parent: app, children: { source: app }
    
    @assert controller.get('user_controller') instanceof DummyApp.UserController
    @assert controller.get('main_controller') instanceof DummyApp.MainController
    @assertEqual undefined, controller.get('root')
  
  'test child options': ->
    session = new WingmanObject
    children_options = { options: { session } }
    controller = new NestedController parent: {}, children: children_options
    @assertEqual session, controller.get('logged_in_controller.welcome_controller.session')
  
  'test child classes': ->
    instantiated_classes = []
    class DummyCounter extends WingmanObject
      @include FamilyMember
      
      constructor: ->
        @parent = {}
        @familize 'controller'
        instantiated_classes.push @constructor.name
    
    class BaseController extends DummyCounter
    class BaseController.Controller extends DummyCounter
    class BaseController.UserController extends DummyCounter
    class BaseController.MailController extends DummyCounter
    class BaseController.MailView extends DummyCounter
    
    new BaseController
    @assertEqual 3, instantiated_classes.length
    @assertContains instantiated_classes, 'BaseController'
    @assertContains instantiated_classes, 'MailController'
    @assertContains instantiated_classes, 'UserController'
  