module.exports = class Template
  @compile = (source) ->
    template = new @ source
    (el, context) ->
      template.evaluate el, context
  
  constructor: (source) ->
    @tree = Parser.parse source
  
  evaluate: (el, context) ->
    if @tree.source
      el.innerHTML = context.get @tree.source
      context.observe @tree.source, (newValue) =>
        el.innerHTML = newValue
    else
      for child in @tree.children
        options = { scope: el }
        options[key] = value for key, value of child
        HandlerFactory.create options, context

Parser = require './template/parser'
HandlerFactory = require './template/handler_factory'
#ElementHandler = require './template/handler_factory/element_handler'
Fleck = require 'fleck'
