Wingman = require '../wingman'
Navigator = require './shared/navigator'

module.exports = class extends Wingman.Object
  @include Navigator
  
  constructor: (view) ->
    @set view: view
    @set state: view.state
    @setupBindings()
    super()
    @ready?()
  
  setupBindings: ->
    @setupBinding eventName, methodName for eventName, methodName of @bindings
  
  setupBinding: (eventName, methodName) ->
    # When Function#bind is fully supported (not supported on iOS5 for instance) we can do this
    # @get('view').bind eventName, @[methodName].bind(@)
    @get('view').bind eventName, (args...) => @[methodName] args...
