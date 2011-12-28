Value = require '../../../lib/wingman/template/parser/value'
Element = require '../../../lib/wingman/template/node_interpreter/element'
Wingman = require '../../../.'
Janitor = require 'janitor'
document = require('jsdom').jsdom()

module.exports = class extends Janitor.TestCase
  'test simple element node': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('test')

    scope = []
    ni = new Element node_data, scope, null, document
    @assert ni.dom_element
    @assert_equal 'DIV', ni.dom_element.tagName
  
  'test simple element node in dom scope': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')

    scope = document.createElement 'li'
    ni = new Element node_data, scope, null, document

    @assert ni.dom_element
    @assert_equal 'DIV', ni.dom_element.tagName
    @assert_equal 'LI', ni.dom_element.parentNode.tagName
  
  'test nested element nodes': ->
    node_data = 
      type: 'element'
      tag: 'div'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('test')
      ]

    scope = []

    ni = new Element node_data, scope, null, document
    @assert ni.dom_element
    @assert_equal 'DIV', ni.dom_element.tagName
    @assert_equal 1, ni.dom_element.childNodes.length
    @assert_equal 'SPAN', ni.dom_element.childNodes[0].tagName
    @assert_equal 'test', ni.dom_element.childNodes[0].innerHTML

  'test element node with dynamic value': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')

    context = new Wingman.Object
    context.set name: 'Rasmus'
    ni = new Element node_data, [], context, document

    @assert_equal 'Rasmus', ni.dom_element.innerHTML
  
  'test element node with dynamic value and defered update': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')

    context = new Wingman.Object
    context.set name: 'John'
    ni = new Element node_data, [], context, document
    @assert_equal 'John', ni.dom_element.innerHTML
    context.set name: 'Rasmus'

    @assert_equal 'Rasmus', ni.dom_element.innerHTML
  
  'test element node with dynamic nested value and defered update': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{user.name}')

    user = new Wingman.Object
    user.set name: 'John'
    context = new Wingman.Object
    context.set {user}
    ni = new Element node_data, [], context, document
    @assert_equal 'John', ni.dom_element.innerHTML
    user.set name: 'Rasmus'

    @assert_equal 'Rasmus', ni.dom_element.innerHTML
  
  'test element node with single static style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
    
    ni = new Element node_data, [], null, document
    
    @assert_equal 'red', ni.dom_element.style.color
  
  'test element node with single dynamic style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new Wingman.Object
    context.set color: 'red'
    ni = new Element node_data, [], context, document
    
    @assert_equal 'red', ni.dom_element.style.color
  
  'test deferred reset with element node with single dynamic style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new Wingman.Object
    context.set color: 'red'
    ni = new Element node_data, [], context, document
    context.set color: 'blue'
    @assert_equal 'blue', ni.dom_element.style.color
