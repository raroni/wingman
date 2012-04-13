ForBlockHandler = require './handler_factory/for_block_handler'
ChildViewHandler = require './handler_factory/child_view_handler'
ConditionalHandler = require './handler_factory/conditional_handler'
ElementHandler = require './handler_factory/element_handler'
TextHandler = require './handler_factory/text_handler'

MAP =
  for: ForBlockHandler
  childView: ChildViewHandler
  conditional: ConditionalHandler
  element: ElementHandler
  text: TextHandler

exports.create = (@options, @context) ->
  klass = MAP[@options.type]
  if klass
    delete options.type
    new klass @options, @context
  else
    throw new Error "Cannot create unknown node type (#{@options.type})!"
