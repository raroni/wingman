document = require('jsdom').jsdom()
Janitor = require 'janitor'
TextHandler = require '../../../../lib/wingman/template/handler_factory/text_handler'
Wingman = require '../../../../.'

module.exports = class TextHandlerTest extends Janitor.TestCase
  setup: ->
    Wingman.document = document
    @parent = Wingman.document.createElement 'div'
  
  teardown: ->
    delete Wingman.document
  
  'test simple text node': ->
    textNode =
      type: 'text'
      value: 'hello'
    
    handler = new TextHandler textNode, @parent
    textNode = handler.textNode
    @assert textNode
    @assertEqual 'hello', textNode.nodeValue
    @assertEqual @parent, textNode.parentNode
  
  'test remove': ->
    textNode =
      type: 'text'
      value: 'hello'
    
    textNode = new TextHandler textNode, @parent
    @assert @parent.hasChildNodes()
    textNode.remove()
    @assert !@parent.hasChildNodes()
