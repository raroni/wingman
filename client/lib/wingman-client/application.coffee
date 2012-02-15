Wingman = require '../wingman-client'
Module = require './shared/module'
Events = require './shared/events'
WingmanObject = require './shared/object'
Navigator = require './shared/navigator'
Fleck = require 'fleck'

createSessionClass = ->
  class Session extends Wingman.Model
    @storage 'local', namespace: 'sessions'

module.exports = class Application extends Module
  @include Navigator
  @include Events
  
  constructor: (options) ->
    throw new Error 'You cannot instantiate two Wingman apps at the same time.' if @constructor.__super__.constructor.instance
    @constructor.__super__.constructor.instance = @
    
    session_class = createSessionClass()
    @session = new session_class id: 1
    @shared = new WingmanObject
    
    for key, value of @constructor
      @constructor.RootView[key] = value if key.match("(.+)View$") && key != 'RootView'
    
    @bind 'viewCreated', @buildController
    
    @el = options.el if options.el?
    @view = options.view || @buildView()
    
    Wingman.window.addEventListener 'popstate', @handlePopStateChange
    @updatePath()
    @session.load()
    @ready?()
  
  buildView: ->
    view = new @constructor.RootView parent: @, el: @el, session: @session, shared: @shared
    view.bind 'descendantCreated', (view) => @trigger 'viewCreated', view
    @trigger 'viewCreated', view
    view.render()
    view
  
  buildController: (view) =>
    parts = view.path().split '.'
    scope = @constructor
    for part in parts
      klass_name = Fleck.camelize "#{part}_controller", true
      scope = scope[klass_name]
    new scope view
  
  handlePopStateChange: (e) =>
    if Wingman.window.navigator.userAgent.match('WebKit') && !@_first_run
      @_first_run = true
    else
      @updatePath()
  
  childOptions: ->
    {
      source: @,
      options: {
        session: @session,
        shared: @shared
      }
    }
  
  updatePath: ->
    @shared.set path: Wingman.document.location.pathname.substr(1)
  
  findView: (path) ->
    @view.get path
