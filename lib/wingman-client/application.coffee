Wingman = require '../wingman-client'
Events = require './shared/events'
WingmanObject = require './shared/object'
Navigator = require './shared/navigator'
Fleck = require 'fleck'

module.exports = class Application extends WingmanObject
  @include Navigator
  @include Events
  
  constructor: (options) ->
    throw new Error 'You cannot instantiate two Wingman apps at the same time.' if @constructor.__super__.constructor.instance
    @constructor.__super__.constructor.instance = @
    
    for key, value of @constructor
      @constructor.RootView[key] = value if key.match("(.+)View$") && key != 'RootView'
    
    @bind 'viewCreated', @buildController
    
    @el = options.el if options.el?
    @view = options.view || @buildView()
    
    Wingman.window.addEventListener 'popstate', @handlePopStateChange
    @updatePath()
    @ready?()
  
  buildView: ->
    view = new @constructor.RootView parent: @, el: @el, app: @
    view.bind 'descendantCreated', (view) => @trigger 'viewCreated', view
    @trigger 'viewCreated', view
    view.render()
    view
  
  buildController: (view) =>
    Controller = @controllerClassForView view
    new Controller view if Controller
  
  controllerClassForView: (view) ->
    parts = view.path().split '.'
    scope = @constructor
    for part in parts
      klass_name = Fleck.camelize "#{part}_controller", true
      scope = scope[klass_name]
      return undefined unless scope
    scope
  
  handlePopStateChange: (e) =>
    if Wingman.window.navigator.userAgent.match('WebKit') && !@_first_run
      @_first_run = true
    else
      @updateNavigationOptions e.state
      @updatePath()
  
  updatePath: ->
    @set path: Wingman.document.location.pathname.substr(1)
  
  updateNavigationOptions: (options) ->
    @set navigation_options: options
  
  findView: (path) ->
    @view.get path
