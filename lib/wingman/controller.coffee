Module = require './shared/module'
ChildInstantiator = require './shared/child_instantiator'
Navigator = require './shared/navigator'

module.exports = class extends Module
  @include ChildInstantiator
  @include Navigator
  
  constructor: (options) ->
    @view = options.view
    @parent = options.parent
    @setupChildControllers()
  
  activate: ->
    @parent.deactivateChildrenExcept @name
    @active = true
  
  deactivate: ->
    @active = false
  
  isActive: ->
    @active
