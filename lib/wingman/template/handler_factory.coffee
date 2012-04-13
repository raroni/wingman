exports.create = (@options, @scope, @context) ->
  if @options.type == 'for'
    new ForBlockHandler @options, @scope, @context
  else if @options.type == 'childView'
    new ChildViewHandler @options, @scope, @context
  else if @options.type == 'conditional'
    new ConditionalHandler @options, @scope, @context
  else if @options.type == 'element'
    new ElementHandler @options, @scope, @context
  else if @options.type == 'text'
    new TextHandler @options, @scope, @context
  else
    throw new Error "Cannot create unknown node type (#{@options.type})!"

ForBlockHandler = require './handler_factory/for_block_handler'
ChildViewHandler = require './handler_factory/child_view_handler'
ConditionalHandler = require './handler_factory/conditional_handler'
ElementHandler = require './handler_factory/element_handler'
TextHandler = require './handler_factory/text_handler'
