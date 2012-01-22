Janitor = require 'janitor'
Module = require '../../../lib/wingman/shared/module'
ChildInstantiator = require '../../../lib/wingman/shared/child_instantiator'

DummyController = class extends Module
  @include ChildInstantiator

Controller = class
  constructor: (@view) ->

DummyController.UserController = class extends Controller
DummyController.UserView = class
DummyController.MailController = class extends Controller
DummyController.MailView = class

module.exports = class extends Janitor.TestCase
  setup: ->
    @dummy_controller = new DummyController
  
  'test find child controllers': ->
    @child_controllers = @dummy_controller.findChildControllers()
    @assertEqual 2, @child_controllers.length
    @assertContains @child_controllers, DummyController.UserController
    @assertContains @child_controllers, DummyController.MailController
  
  'test single controller setup': ->
    @dummy_controller.setupController DummyController.UserController
    @assertEqual 1, Object.keys(@dummy_controller.controllers).length
    @assert @dummy_controller.controllers['user'].view instanceof DummyController.UserView
  
  'test setup all controllers': ->
    @dummy_controller.setupChildControllers()
    @assertEqual 2, Object.keys(@dummy_controller.controllers).length
    @assert @dummy_controller.controllers['mail'] instanceof DummyController.MailController
    @assert @dummy_controller.controllers['user'] instanceof DummyController.UserController
