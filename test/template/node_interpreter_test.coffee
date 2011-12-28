Janitor = require 'janitor'
NodeInterpreter = require '../../lib/wingman/template/node_interpreter'
Value = require '../../lib/wingman/template/parser/value'
Wingman = require '../..'
document = require('jsdom').jsdom()

module.exports = class extends Janitor.TestCase
  'test simple element node': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')

    scope = []
    ni = new NodeInterpreter node_data, scope, null, document
    @assert ni.element
    @assert_equal 'DIV', ni.element.tagName

  'test simple element node in dom scope': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')

    scope = document.createElement 'li'
    ni = new NodeInterpreter node_data, scope, null, document

    @assert ni.element
    @assert_equal 'DIV', ni.element.tagName
    @assert_equal 'LI', ni.element.parentNode.tagName

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

    ni = new NodeInterpreter node_data, scope, null, document
    @assert ni.element
    @assert_equal 'DIV', ni.element.tagName
    @assert_equal 1, ni.element.childNodes.length
    @assert_equal 'SPAN', ni.element.childNodes[0].tagName
    @assert_equal 'test', ni.element.childNodes[0].innerHTML

  'test element node with dynamic value': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')

    context = new Wingman.Object
    context.set name: 'Rasmus'
    ni = new NodeInterpreter node_data, [], context, document

    @assert_equal 'Rasmus', ni.element.innerHTML

  'test element node with dynamic value and defered update': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')

    context = new Wingman.Object
    context.set name: 'John'
    ni = new NodeInterpreter node_data, [], context, document
    @assert_equal 'John', ni.element.innerHTML
    context.set name: 'Rasmus'

    @assert_equal 'Rasmus', ni.element.innerHTML

  'test element node with dynamic nested value and defered update': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{user.name}')

    user = new Wingman.Object
    user.set name: 'John'
    context = new Wingman.Object
    context.set {user}
    ni = new NodeInterpreter node_data, [], context, document
    @assert_equal 'John', ni.element.innerHTML
    user.set name: 'Rasmus'

    @assert_equal 'Rasmus', ni.element.innerHTML

  'test for node': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'li'
        value: new Value('{user}')
      ]
    
    context = new Wingman.Object
    context.set users: ['Rasmus', 'John']

    element = document.createElement 'ol'
    ni = new NodeInterpreter node_data, element, context, document
    
    @assert !ni.element
    @assert_equal 2, element.childNodes.length
    @assert_equal 'Rasmus', element.childNodes[0].innerHTML
    @assert_equal 'John', element.childNodes[1].innerHTML

  'test for node with deferred push': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'li'
        value: new Value('{user}')
      ]
    
    context = new Wingman.Object
    context.set users: ['Rasmus', 'John']

    element = document.createElement 'ol'
    new NodeInterpreter node_data, element, context, document
    
    @assert_equal 2, element.childNodes.length
    context.get('users').push 'Joe'
    @assert_equal 3, element.childNodes.length
    @assert_equal 'Joe', element.childNodes[2].innerHTML
  
  'test for node with deferred remove': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'li'
        value: new Value('{user}')
      ]
    
    context = new Wingman.Object
    context.set users: ['Rasmus', 'John']

    element = document.createElement 'ol'
    new NodeInterpreter node_data, element, context, document
    
    @assert_equal 2, element.childNodes.length
    context.get('users').remove 'John'
    @assert_equal 1, element.childNodes.length

  'test for node with deferred reset': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'li'
        value: new Value('{user}')
      ]
    
    context = new Wingman.Object
    context.set users: ['Rasmus', 'John']

    element = document.createElement 'ol'
    new NodeInterpreter node_data, element, context, document
    
    @assert_equal 2, element.childNodes.length
    context.set users: ['Oliver']
    @assert_equal 1, element.childNodes.length
    @assert_equal 'Oliver', element.childNodes[0].innerHTML

  'test element node with single static style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
    
    ni = new NodeInterpreter node_data, [], null, document
    
    @assert_equal 'red', ni.element.style.color

  'test element node with single dynamic style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new Wingman.Object
    context.set color: 'red'
    ni = new NodeInterpreter node_data, [], context, document
    
    @assert_equal 'red', ni.element.style.color

  'test deferred reset with element node with single dynamic style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new Wingman.Object
    context.set color: 'red'
    ni = new NodeInterpreter node_data, [], context, document
    context.set color: 'blue'
    @assert_equal 'blue', ni.element.style.color
