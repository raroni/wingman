Wingman = require '../wingman'
Module = require './shared/module'
ChildInstantiator = require './shared/child_instantiator'
ObjectTree = require './object_tree'
Navigator = require './shared/navigator'

module.exports = class extends Module
  @include ChildInstantiator
  @include Navigator
  
  constructor: (options) ->
    throw new Error 'You cannot instantiate two Wingman apps at the same time.' if @constructor.__super__.constructor.instance
    @constructor.__super__.constructor.instance = @
    
    @el = options.el if options.el?
    @view = options.view || @buildView()
    
    @setupControllers()
    Wingman.window.addEventListener 'popstate', @handlePopStateChange
    @navigate ''
    @ready?()
  
  buildView: ->
    new @constructor.RootView parent: @, child_source: @, el: @el
    
  setupControllers: ->
    @controllers = new ObjectTree @, 'Controller', attach_to: 'tree'

  handlePopStateChange: (e) =>
    if Wingman.window.navigator.userAgent.match('WebKit') && !@_first_run
      @first_run = true
    else
      @checkURL()
  
  findView: (path) ->
    @view.get path
  
  # This method should be refactored someday. Perhaps out into new class Router?
  checkURL: ->
    if @routes
      path = Wingman.document.location.pathname.substr 1
      controller_key = @routes[path]
      if controller_key
        controller = @controllers.get controller_key
        if controller
          controller.activate()
        else
          throw new Error("Controller #{controller_key} does not exist.")
