module.exports = class ChildViewHandler
  constructor: (@options, @scope, @context) ->
    @view = @context.createChild @options.name, @viewOptions()
    element = @view.el
    @scope.appendChild element
  
  viewOptions: ->
    options = { render: true }
    options.properties = properties if properties = @viewProperties()
    options
  
  viewProperties: ->
    if @context.get @options.name
      properties = {}
      properties[@options.name] = @context.get @options.name 
      properties
  
  remove: ->
    @view.remove()
