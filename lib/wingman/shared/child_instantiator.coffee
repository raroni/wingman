Fleck = require 'fleck'

module.exports =
  setupChildControllers: ->
    for controller_class in @findChildControllers()
      @setupController controller_class

  setupController: (controller_class) ->
    (@controllers ||= {})[controller_class._name] = @buildController controller_class

  buildController: (controller_class) ->
    view_name = Fleck.camelize(controller_class._name, true) + 'View'
    view_class = @constructor[view_name]
      
    template_path_keys = [controller_class._name]
    template_path_keys.unshift @path() if @path()
    view = new view_class parent_el: (@view?.el || @el), template_path: template_path_keys.join('.')
    new controller_class view: view, parent: @

  pathKeys: ->
    return [] unless @parent
    path_keys = [@constructor._name]
    path_keys.unshift path_key for path_key in @parent.pathKeys()
    path_keys
    
  path: ->
    @pathKeys().join '.'
      
  findChildControllers: ->
    controllers = []
    for key, value of @constructor
      match = key.match "(.*)Controller$"
      if match
        value._name = Fleck.underscore match[1]
        controllers.push value
    controllers
  
  deactivateDescendantsExceptChild: (controller_name) ->
    controller.deactivate() for name, controller of @controllers when name != controller_name
    @parent?.deactivateDescendantsExceptChild @constructor._name
