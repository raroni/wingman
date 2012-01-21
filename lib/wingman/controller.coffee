Module = require './module'
ChildInstantiator = require './child_instantiator'

module.exports = class extends Module
  @include ChildInstantiator
  
  constructor: (options) ->
    @el = options.el
    @setupChildControllers()
