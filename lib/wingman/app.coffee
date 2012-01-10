Fleck = require 'fleck'

module.exports = class
  constructor: (options) ->
    @el = options.el
    @setupControllers()
    @ready?()

  setupControllers: ->
    @controllers = []
    for controller_class in @findControllers()
      @setupController controller_class
  
  setupController: (controller_class) ->
    view_name = Fleck.camelize(controller_class._name, true) + 'View'
    view_class = @constructor[view_name]
    view = new view_class parent_el: @el, template_path: controller_class._name
    controller = new controller_class view
    @controllers.push controller
  
  findControllers: ->
    controllers = []
    for key, value of @constructor
      match = key.match "(.*)Controller$"
      if match
        value._name = Fleck.underscore match[1]
        controllers.push value
    controllers
