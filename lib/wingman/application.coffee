Wingman = require '../wingman'
Module = require './shared/module'
WingmanObject = require './shared/object'
FamilyMember = require './shared/family_member'
Navigator = require './shared/navigator'

createSessionClass = ->
  class Session extends Wingman.Model
    @storage 'local', namespace: 'sessions'

module.exports = class extends Module
  @include FamilyMember
  @include Navigator
  
  constructor: (options) ->
    throw new Error 'You cannot instantiate two Wingman apps at the same time.' if @constructor.__super__.constructor.instance
    @constructor.__super__.constructor.instance = @
    
    session_class = createSessionClass()
    @session = new session_class id: 1
    @shared = new WingmanObject
    
    @el = options.el if options.el?
    @view = options.view || @buildView()
    
    @setupController()
    Wingman.window.addEventListener 'popstate', @handlePopStateChange
    @updatePath()
    @session.load()
    @ready?()
  
  buildView: ->
    new @constructor.RootView parent: @, el: @el, children: @childOptions()
  
  setupController: ->
    @controller = new @constructor.RootController parent: @, children: @childOptions()

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
    @session.set path: Wingman.document.location.pathname.substr(1)
  
  findView: (path) ->
    @view.get path
