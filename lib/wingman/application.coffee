Wingman = require '../wingman'
Module = require './shared/module'
WingmanObject = require './shared/object'
FamilyMember = require './shared/family_member'
Navigator = require './shared/navigator'

class Session extends Wingman.Model
  @storage 'local', namespace: 'sessions'

module.exports = class extends Module
  @include FamilyMember
  @include Navigator
  
  constructor: (options) ->
    throw new Error 'You cannot instantiate two Wingman apps at the same time.' if @constructor.__super__.constructor.instance
    @constructor.__super__.constructor.instance = @
    
    @session = new Session id: 1
    
    @el = options.el if options.el?
    @view = options.view || @buildView()
    
    @setupController()
    Wingman.window.addEventListener 'popstate', @handlePopStateChange
    @updatePath()
    @session.load()
    @ready?()
  
  buildView: ->
    new @constructor.RootView parent: @, el: @el, children: { source: @, options: { session: @session } }
  
  setupController: ->
    @controller = new @constructor.RootController parent: @, children: { source: @, options: { session: @session } }

  handlePopStateChange: (e) =>
    if Wingman.window.navigator.userAgent.match('WebKit') && !@_first_run
      @_first_run = true
    else
      @updatePath()
  
  updatePath: ->
    @session.set path: Wingman.document.location.pathname.substr(1)
  
  findView: (path) ->
    @view.get path
