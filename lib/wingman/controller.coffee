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
    @ready?()
  
  activate: ->
    @parent.deactivateDescendantsExceptChild @name
    @is_active = true
    @view.activate()
  
  deactivate: ->
    @is_active = false
    @view.deactivate()
