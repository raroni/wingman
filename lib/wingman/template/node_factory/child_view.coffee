module.exports = class ChildView
  constructor: (@nodeData, @scope, @context) ->
    @view = @context.createChild @nodeData.name, @options()
    element = @view.el
    @scope.appendChild element
  
  options: ->
    options = { render: true }
    options.properties = properties if properties = @properties()
    options
    
  properties: ->
    if @context.get @nodeData.name
      properties = {}
      properties[@nodeData.name] = @context.get @nodeData.name 
      properties
  
  remove: ->
    @view.remove()
