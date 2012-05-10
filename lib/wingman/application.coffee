Wingman = require '../wingman'
Events = require './shared/events'
Navigator = require './shared/navigator'
Fleck = require 'fleck'

Application = Wingman.Object.extend
  initialize: (options) ->
    throw new Error 'You cannot instantiate two Wingman apps at the same time.' if Application.instance
    Application.instance = @
    
    @bind 'viewCreated', @buildController, @
    
    @el = options?.el || Wingman.document.body
    @view = options?.view || @buildView()
    
    Wingman.window.addEventListener 'popstate', @handlePopStateChange.bind(@)
    @updatePath()
    @ready?()
  
  buildView: ->
    view = new @constructor.RootView parent: @, el: @el, state: @state, childClasses: @constructor.rootViewSiblings()
    view.bind 'descendantCreated', (view) => @trigger 'viewCreated', view
    @trigger 'viewCreated', view
    view.render()
    view
  
  getState: ->
    @_state ||= @createState()
  
  createState: ->
    new Wingman.Object
  
  buildController: (view) ->
    Controller = @controllerClassForView view
    new Controller view if Controller
  
  controllerClassForView: (view) ->
    return @constructor.RootController if view.path().length == 0
    
    scope = @constructor
    for name in @viewStringPath(view)
      controllerName = "#{name}Controller"
      scope = scope[controllerName]
      return undefined unless scope
    
    scope
  
  viewStringPath: (view) ->
    scope = @constructor
    names = []
    for part in view.path()
      name = null
      for key, value of scope
        if value == part
          name = key
          break
      
      scope = scope[name]
      return undefined unless scope
      names.push name.replace /View$/, ''
    names
  
  handlePopStateChange: (e) ->
    if Wingman.window.navigator.userAgent.match('WebKit') && !@_firstRun
      @_firstRun = true
    else
      @updateNavigationOptions e.state
      @updatePath()
  
  updatePath: ->
    @set path: Wingman.document.location.pathname.substr(1)
  
  updateNavigationOptions: (options) ->
    @set navigationOptions: options
  
  findView: (path) ->
    @view.get path

Application.prototype.include Navigator, Events
Application.rootViewSiblings = ->
  views = {}
  for key, value of @
    views[key] = value if key.match("(.+)View$") && key != 'RootView'
  views

module.exports = Application
