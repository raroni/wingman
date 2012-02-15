module.exports = class ChildView
  constructor: (@node_data, @scope, @context) ->
    @view = @context.createChildView @node_data.name
    element = @view.el
    @scope.appendChild element
  
  remove: ->
    @view.remove()
