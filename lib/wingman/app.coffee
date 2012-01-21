Module = require './shared/module'
ChildInstantiator = require './shared/child_instantiator'

module.exports = class extends Module
  @include ChildInstantiator
  
  constructor: (options) ->
    throw new Error 'You cannot instantiate two Wingman apps at the same time.' if @constructor.__super__.constructor.instance
    @constructor.__super__.constructor.instance = @
    @el = options.el
    @setupChildControllers()
    @ready?()
