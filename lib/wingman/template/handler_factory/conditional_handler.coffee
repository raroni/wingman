HandlerFactory = require '../handler_factory'

module.exports = class ConditionalHandler
  constructor: (@options, @scope, @context) ->
    @handlers = []
    @context.observe @options.source, @update
    @update @context.get(@options.source)
  
  add: (currentValue) ->
    children = (currentValue && @options.trueChildren) || @options.falseChildren
    
    if children
      for options in children
        handler = HandlerFactory.create options, @scope, @context
        @handlers.push handler
  
  remove: ->
    handler.remove() while handler = @handlers.shift()
  
  update: (currentValue) =>
    @remove()
    @add currentValue
