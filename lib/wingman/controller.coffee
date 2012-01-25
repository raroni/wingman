WingmanObject = require './shared/object'
Wingman = require '../wingman'
FamilyMember = require './shared/family_member'
ObjectTree = require './object_tree'
Navigator = require './shared/navigator'

module.exports = class extends WingmanObject
  @include FamilyMember
  @include Navigator
  
  constructor: (options) ->
    @parent = options.parent if options?.parent?
    new ObjectTree @, 'Controller', child_source: options?.child_source
    @view = options?.view || @findView()
    @ready?()
  
  activateDescendant: (chain) ->
    chain_parts = chain.split '.'
    child_key = chain_parts[0]
    child = @get child_key
    if @one_child_at_a_time
      child.activate()
      # This is UGLY and should be refactored!
      for name, controller of @
        if controller instanceof Wingman.Controller && controller != child && name != 'parent'
          controller.deactivate()
      # #######################################
    child.activateDescendant chain_parts.slice(1).join('.') unless chain_parts.length == 1
  
  activate: ->
    @is_active = true
    @view.activate()
  
  deactivate: ->
    @is_active = false
    @view.deactivate()
  
  findView: (path) ->
    @parent.findView(path || @path())
