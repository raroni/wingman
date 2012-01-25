Wingman = require '../wingman'
Module = require './shared/module'
FamilyMember = require './shared/family_member'
Navigator = require './shared/navigator'

module.exports = class extends Module
  @include FamilyMember
  @include Navigator
  
  constructor: (options) ->
    throw new Error 'You cannot instantiate two Wingman apps at the same time.' if @constructor.__super__.constructor.instance
    @constructor.__super__.constructor.instance = @
    
    @el = options.el if options.el?
    @view = options.view || @buildView()
    
    @setupController()
    Wingman.window.addEventListener 'popstate', @handlePopStateChange
    @checkURL()
    @ready?()
  
  buildView: ->
    new @constructor.RootView parent: @, child_source: @, el: @el
    
  setupController: ->
    @controller = new @constructor.RootController parent: @, child_source: @

  handlePopStateChange: (e) =>
    if Wingman.window.navigator.userAgent.match('WebKit') && !@_first_run
      @_first_run = true
    else
      @checkURL()
  
  findView: (path) ->
    @view.get path
  
  # This method should be refactored someday. Perhaps out into new class Router?
  checkURL: ->
    if @routes
      path = Wingman.document.location.pathname.substr 1
      chain = @routes[path]
      if chain
        chain_parts = chain.split '.'
        child_key = chain_parts[0]
        child = @controller.get child_key
        if @one_child_at_a_time
          child.activate()
          # This is UGLY and should be refactored!
          for name, controller of @controller
            if controller instanceof Wingman.Controller && controller != child && name != 'parent'
              controller.deactivate()
          # #######################################
        child.activateDescendant chain_parts.slice(1).join('.') unless chain_parts.length == 1
