Module = require './shared/module'
ChildInstantiator = require './shared/child_instantiator'

module.exports = class extends Module
  @include ChildInstantiator
  
  constructor: (options) ->
    @el = options.el
    @setupChildControllers()
