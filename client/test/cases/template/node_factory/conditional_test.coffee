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
        type: 'element'
        tag: 'span'
        value: new Value('user')
      ]
    
    context = new WingmanObject
    context.set something: true
    new Conditional node_data, @parent, context
    
    element = @parent.childNodes[0]
    @assert !element.style.display
    
    context.set something: false
    @assertEqual 'none', element.style.display
  
  'test if else conditonal': ->
    node_data =
      type: 'conditional'
      source: 'early'
      true_children: [
        type: 'element'
        tag: 'span'
        value: new Value('good morning')
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
    @assert !child_nodes[0].style.display
    @assertEqual 'none', child_nodes[1].style.display
    
    context.set early: false
    
    @assertEqual 'none', child_nodes[0].style.display
    @assert !child_nodes[1].style.display
