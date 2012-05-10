Wingman = require '../wingman'
Navigator = require './shared/navigator'

Controller = Wingman.Object.extend
  state: null
  
  initialize: (view) ->
    @view = view
    @state = view.state
    @setupBindings()
    @_super()
    @ready?()
  
  setupBindings: ->
    @setupBinding eventName, methodName for eventName, methodName of @bindings
  
  setupBinding: (eventName, methodName) ->
    # When Function#bind is fully supported (not supported on iOS5 for instance) we can do this
    # @get('view').bind eventName, @[methodName].bind(@)
    @get('view').bind eventName, (args...) => @[methodName] args...

Controller.prototype.include Navigator

module.exports = Controller
