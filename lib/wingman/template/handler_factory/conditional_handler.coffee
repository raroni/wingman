HandlerFactory = require '../handler_factory'

module.exports = class ConditionalHandler
  constructor: (@options, @scope, @context) ->
    @handlers = []
    @context.observe @options.source, @update
    @update @context.get(@options.source)
  
  add: (currentValue) ->
    if currentValue
      for childOptions in @options.trueChildren
        handler = HandlerFactory.create childOptions, @scope, @context
        @handlers.push handler
    else if @options.falseChildren
      for childOptions in @options.falseChildren
        handler = HandlerFactory.create childOptions, @scope, @context
        @handlers.push handler
  
  remove: ->
    handler.remove() while handler = @handlers.shift()
  
  update: (currentValue) =>
    @remove()
    @add currentValue
