document = require('jsdom').jsdom()
Janitor = require 'janitor'
Conditional = require '../../../../lib/wingman-client/template/node_factory/conditional'
Wingman = require '../../../../.'
Value = require '../../../../lib/wingman-client/template/parser/value'
WingmanObject = require '../../../../lib/wingman-client/shared/object'

module.exports = class ConditionalTest extends Janitor.TestCase
  setup: ->
    Wingman.document = document
    @parent = Wingman.document.createElement 'div'

  'test simple conditional': ->
    nodeData =
      type: 'conditional'
      source: 'something'
      trueChildren: [
        {
          type: 'element'
          tag: 'span'
          value: new Value('user')
        },
        {
          type: 'element'
          tag: 'span'
          value: new Value('user2')
        }
      ]
    
    context = new WingmanObject
    context.set something: true
    new Conditional nodeData, @parent, context
    
    childNodes = @parent.childNodes
    @assertEqual 2, childNodes.length
    @assertEqual 'user', childNodes[0].innerHTML
    @assertEqual 'user2', childNodes[1].innerHTML
    context.set something: false
    @assertEqual 0, childNodes.length
  
  'test if else conditonal': ->
    nodeData =
      type: 'conditional'
      source: 'early'
      trueChildren: [
        {
          type: 'element'
          tag: 'span'
          value: new Value('good morning')
        },
        {
          type: 'element'
          tag: 'span'
          value: new Value('good morning again')
        }
      ]
      falseChildren: [
        type: 'element'
        tag: 'span'
        value: new Value('good evening')
      ]
    
    context = new WingmanObject
    context.set early: true
    new Conditional nodeData, @parent, context
    
    childNodes = @parent.childNodes
    @assertEqual 2, childNodes.length
    @assertEqual 'good morning', childNodes[0].innerHTML
    @assertEqual 'good morning again', childNodes[1].innerHTML
    context.set early: false
    @assertEqual 1, childNodes.length
    @assertEqual 'good evening', childNodes[0].innerHTML
