WingmanObject = require '../../shared/object'

module.exports = WingmanObject.extend
  initialize: (@options, @context) ->
    @view = @context.createChild @viewName(), @viewOptions()
    @options.scope.appendChild @view.el
  
  viewOptions: ->
    options = { render: true }
    options.properties = properties if properties = @viewProperties()
    options
  
  viewProperties: ->
    properties = {}
    if @options.name && @context.get @options.name
      properties[@options.name] = @context.get @options.name
    if @options.properties
      for key in @options.properties
        properties[key] = @context.get key
    properties
  
  remove: ->
    @view.remove()
  
  viewName: ->
    if @options.name
      @options.name
    else
      @context.get @options.path
