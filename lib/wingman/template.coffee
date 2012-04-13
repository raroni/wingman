module.exports = class Template
  @compile = (source) ->
    template = new @ source
    (el, context) ->
      template.evaluate el, context
  
  constructor: (source) ->
    @tree = Parser.parse source
  
  evaluate: (el, context) ->
    for options in @tree.children
      HandlerFactory.create options, el, context

Parser = require './template/parser'
HandlerFactory = require './template/handler_factory'
Fleck = require 'fleck'
