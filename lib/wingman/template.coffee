module.exports = class
  @document: document if window?

  @compile = (source) ->
    template = new @ source
    (context) ->
      template.evaluate context
  
  constructor: (source) ->
    @tree = Parser.parse source

  evaluate: (context) ->
    @elements = []
    for node_data in @tree.children
      new NodeInterpreter node_data, @elements, context
    @elements

Parser = require './template/parser'
NodeInterpreter = require './template/node_interpreter'
Fleck = require 'fleck'
