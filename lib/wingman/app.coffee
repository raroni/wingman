Wingman = require '../wingman'
Module = require './shared/module'
ChildInstantiator = require './shared/child_instantiator'
Navigator = require './shared/navigator'

module.exports = class extends Module
  @include ChildInstantiator
  @include Navigator
  
  constructor: (options) ->
    throw new Error 'You cannot instantiate two Wingman apps at the same time.' if @constructor.__super__.constructor.instance
    @constructor.__super__.constructor.instance = @
    @el = options.el
    @setupChildControllers()
    Wingman.window.addEventListener 'popstate', @handlePopStateChange
    @navigate ''
    @ready?()

  handlePopStateChange: (e) =>
    if Wingman.window.navigator.userAgent.match('WebKit') && !@_first_run
      @first_run = true
    else
      @checkURL()
  
  checkURL: ->
    if @routes
      path = Wingman.document.location.pathname.substr 1
      controller_key = @routes[path]
      if controller_key
        controller = @controllers[controller_key]
        if controller
          controller.activate()
        else
          throw new Error("Controller #{controller_key} does not exist.")
