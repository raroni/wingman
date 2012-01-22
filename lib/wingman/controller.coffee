Module = require './shared/module'
ChildInstantiator = require './shared/child_instantiator'
Navigator = require './shared/navigator'

module.exports = class extends Module
  @include ChildInstantiator
  @include Navigator
  
  constructor: (options) ->
    @el = options.el
    @setupChildControllers()
