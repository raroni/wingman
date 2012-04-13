module.exports = class Template
  @compile = (source) ->
    template = new @ source
    (el, context) ->
      template.evaluate el, context
  
  constructor: (source) ->
    @tree = Parser.parse source
  
  evaluate: (el, context) ->
    for child in @tree.children
      options = { scope: el }
      options[key] = value for key, value of child
      HandlerFactory.create options, context

Parser = require './template/parser'
HandlerFactory = require './template/handler_factory'
Fleck = require 'fleck'
