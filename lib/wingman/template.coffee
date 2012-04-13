module.exports = class Template
  @compile = (source) ->
    template = new @ source
    (el, context) ->
      template.evaluate el, context
  
  constructor: (source) ->
    @tree = Parser.parse source
  
  evaluate: (el, context) ->
    for nodeData in @tree.children
      NodeFactory.create nodeData, el, context

Parser = require './template/parser'
NodeFactory = require './template/node_factory'
Fleck = require 'fleck'
