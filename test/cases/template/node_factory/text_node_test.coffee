document = require('jsdom').jsdom()
Janitor = require 'janitor'
TextNode = require '../../../../lib/wingman/template/node_factory/text_node'
Wingman = require '../../../../.'

module.exports = class TextNodeTest extends Janitor.TestCase
  setup: ->
    Wingman.document = document
    @parent = Wingman.document.createElement 'div'
  
  teardown: ->
    delete Wingman.document
  
  'test simple text node': ->
    textNode =
      type: 'text'
      value: 'hello'
    
    textNode = new TextNode textNode, @parent
    @assert textNode.textNode
    @assertEqual 'hello', textNode.textNode.nodeValue
    @assertEqual @parent, textNode.textNode.parentNode
  
  'test remove': ->
    textNode =
      type: 'text'
      value: 'hello'
    
    textNode = new TextNode textNode, @parent
    @assert @parent.hasChildNodes()
    textNode.remove()
    @assert !@parent.hasChildNodes()
