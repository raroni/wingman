Wingman = require '../wingman'
Events = require './shared/events'
Navigator = require './shared/navigator'
Fleck = require 'fleck'

module.exports = class Application extends Wingman.Object
  @include Navigator
  @include Events
  
  @rootViewSiblings: ->
    views = {}
    for key, value of @
      views[key] = value if key.match("(.+)View$") && key != 'RootView'
    views
  
  constructor: (options) ->
    throw new Error 'You cannot instantiate two Wingman apps at the same time.' if @constructor.__super__.constructor.instance
    @constructor.__super__.constructor.instance = @
    
    @bind 'viewCreated', @buildController
    
    @el = options?.el || Wingman.document.body
    @view = options?.view || @buildView()
    
    Wingman.window.addEventListener 'popstate', @handlePopStateChange
    @updatePath()
    @ready?()
  
  buildView: ->
    view = new @constructor.RootView parent: @, el: @el, state: @get('state'), childClasses: @constructor.rootViewSiblings()
    view.bind 'descendantCreated', (view) => @trigger 'viewCreated', view
    @trigger 'viewCreated', view
    view.render()
    view
  
  state: ->
    @_state ||= @createState()
  
  createState: ->
    new Wingman.Object
  
  buildController: (view) =>
    Controller = @controllerClassForView view
    new Controller view if Controller
  
  controllerClassForView: (view) ->
    parts = view.path().split '.'
    scope = @constructor
    for part in parts
      klassName = Fleck.camelize(part, true) + 'Controller'
      scope = scope[klassName]
      return undefined unless scope
    scope
  
  handlePopStateChange: (e) =>
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
