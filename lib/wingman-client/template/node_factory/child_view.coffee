module.exports = class ChildView
  constructor: (@nodeData, @scope, @context) ->
    @view = @context.createChildView @nodeData.name
    @view.setProperty @nodeData.name, @context.get(@nodeData.name) if @context.get(@nodeData.name)
    element = @view.el
    @scope.appendChild element
  
  remove: ->
    @view.remove()
