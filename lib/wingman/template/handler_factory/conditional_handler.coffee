WingmanObject = require '../../shared/object'
HandlerFactory = require '../handler_factory'

module.exports = WingmanObject.extend
  initialize: ->
    @handlers = []
    @context.observe @options.source, @update.bind(@)
    @update @context[@options.source]
  
  add: (currentValue) ->
    children = (currentValue && @options.trueChildren) || @options.falseChildren
    
    if children
      for child in children
        options = { scope: @options.scope }
        options[key] = value for key, value of child
        handler = HandlerFactory.create options, @context
        @handlers.push handler
  
  remove: ->
    handler.remove() while handler = @handlers.shift()
  
  update: (currentValue) ->
    @remove()
    @add currentValue
