Parser = require './template/parser'
NodeInterpreter = require './template/node_interpreter'
RangoObject = require './object'
Fleck = require 'fleck'

unless window?
  jsdom = require('jsdom').jsdom
  document = jsdom()

module.exports = class
  @compile = (source) ->
    template = new @ source
    (context) ->
      template.evaluate context
  
  constructor: (source) ->
    @tree = Parser.parse source

  evaluate: (context) ->
    @elements = []
    for node_data in @tree.children
      new NodeInterpreter(node_data, @elements, context)
    @elements
