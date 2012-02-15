module.exports = class Template
  @compile = (source) ->
    template = new @ source
    (el, context) ->
      template.evaluate el, context
  
  constructor: (source) ->
    @tree = Parser.parse source

  evaluate: (el, context) ->
    for node_data in @tree.children
      new NodeInterpreter node_data, el, context

Parser = require './template/parser'
NodeInterpreter = require './template/node_interpreter'
Fleck = require 'fleck'
