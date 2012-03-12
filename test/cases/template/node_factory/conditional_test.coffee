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
    node_data =
      type: 'conditional'
      source: 'something'
      true_children: [
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
    new Conditional node_data, @parent, context
    
    child_nodes = @parent.childNodes
    @assertEqual 2, child_nodes.length
    @assertEqual 'user', child_nodes[0].innerHTML
    @assertEqual 'user2', child_nodes[1].innerHTML
    context.set something: false
    @assertEqual 0, child_nodes.length
  
  'test if else conditonal': ->
    node_data =
      type: 'conditional'
      source: 'early'
      true_children: [
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
      false_children: [
        type: 'element'
        tag: 'span'
        value: new Value('good evening')
      ]
    
    context = new WingmanObject
    context.set early: true
    new Conditional node_data, @parent, context
    
    child_nodes = @parent.childNodes
    @assertEqual 2, child_nodes.length
    @assertEqual 'good morning', child_nodes[0].innerHTML
    @assertEqual 'good morning again', child_nodes[1].innerHTML
    context.set early: false
    @assertEqual 1, child_nodes.length
    @assertEqual 'good evening', child_nodes[0].innerHTML
