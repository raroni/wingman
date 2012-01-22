Janitor = require 'janitor'
Module = require '../../../lib/wingman/shared/module'
ChildInstantiator = require '../../../lib/wingman/shared/child_instantiator'

DummyController = class extends Module
  @include ChildInstantiator
  constructor: (@options) ->
  deactivate: ->
    @active = false

MainController = class extends DummyController
MainController.UserController = class extends DummyController
MainController.UserView = class
MainController.MailController = class extends DummyController
MainController.MailView = class

module.exports = class extends Janitor.TestCase
  setup: ->
    @main_controller = new MainController
  
  'test find child controllers': ->
    @child_controllers = @main_controller.findChildControllers()
    @assertEqual 2, @child_controllers.length
    @assertContains @child_controllers, MainController.UserController
    @assertContains @child_controllers, MainController.MailController
  
  'test single controller setup': ->
    @main_controller.setupController MainController.UserController
    @assertEqual 1, Object.keys(@main_controller.controllers).length
    @assert @main_controller.controllers.user instanceof MainController.UserController
    @assertEqual @main_controller, @main_controller.controllers.user.options.parent
    @assert @main_controller.controllers.user.options.view instanceof MainController.UserView
  
  'test setup all controllers': ->
    @main_controller.setupChildControllers()
    @assertEqual 2, Object.keys(@main_controller.controllers).length
    @assert @main_controller.controllers.mail instanceof MainController.MailController
    @assert @main_controller.controllers.user instanceof MainController.UserController
  
  'test deactivation of children': ->
    @main_controller.setupChildControllers()
    @main_controller.deactivateChildrenExcept 'user'
    @assertEqual undefined, @main_controller.controllers.user.active
    @assertEqual false, @main_controller.controllers['mail'].active
