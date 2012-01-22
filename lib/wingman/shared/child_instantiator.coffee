Fleck = require 'fleck'

module.exports =
  setupChildControllers: ->
    for controller_class in @findChildControllers()
      @setupController controller_class

  setupController: (controller_class) ->
    view_name = Fleck.camelize(controller_class._name, true) + 'View'
    view_class = @constructor[view_name]
    view = new view_class parent_el: (@view?.el || @el), template_path: controller_class._name
    controller = new controller_class view: view, parent: @
    (@controllers ||= {})[controller_class._name] = controller

  findChildControllers: ->
    controllers = []
    for key, value of @constructor
      match = key.match "(.*)Controller$"
      if match
        value._name = Fleck.underscore match[1]
        controllers.push value
    controllers
  
  deactivateChildrenExcept: (controller_name) ->
    controller.deactivate() for name, controller of @controllers when name != controller_name
      