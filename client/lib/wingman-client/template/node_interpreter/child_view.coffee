module.exports = class ChildView
  constructor: (@node_data, @scope, @context) ->
    @view = @context.createChildView @node_data.name
    @view.setProperty @node_data.name, @context.get(@node_data.name) if @context.get(@node_data.name)
    element = @view.el
    @scope.appendChild element
  
  remove: ->
    @view.remove()
  
  deactivate: ->
    @view.deactivate()
  
  activate: ->
    @view.activate()
