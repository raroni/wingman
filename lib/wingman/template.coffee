module.exports = class Template
  @compile = (source) ->
    template = new @ source
    (el, context) ->
      template.evaluate el, context
  
  constructor: (source) ->
    @tree = Parser.parse source
  
  evaluate: (el, context) ->
    options = { el, type: 'element' }
    options[key] = value for key, value of @tree
    HandlerFactory.create options, context

Parser = require './template/parser'
HandlerFactory = require './template/handler_factory'
Fleck = require 'fleck'
