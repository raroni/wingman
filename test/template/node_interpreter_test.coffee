Janitor = require 'janitor'
NodeInterpreter = require '../../lib/wingman/template/node_interpreter'
Value = require '../../lib/wingman/template/parser/value'
Wingman = require '../..'
document = require('jsdom').jsdom()

module.exports = class extends Janitor.TestCase
  setup: ->
    Wingman.Template.document = document

  'test simple element node': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')

    scope = []
    interpreter = new NodeInterpreter node_data, scope
    @assert interpreter.element
    @assert_equal 'DIV', interpreter.element.tagName

  'test simple element node in dom scope': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')

    scope = document.createElement 'li'
    interpreter = new NodeInterpreter node_data, scope

    @assert interpreter.element
    @assert_equal 'DIV', interpreter.element.tagName
    @assert_equal 'LI', interpreter.element.parentNode.tagName

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

    interpreter = new NodeInterpreter node_data, scope
    @assert interpreter.element
    @assert_equal 'DIV', interpreter.element.tagName
    @assert_equal 1, interpreter.element.childNodes.length
    @assert_equal 'SPAN', interpreter.element.childNodes[0].tagName
    @assert_equal 'test', interpreter.element.childNodes[0].innerHTML

  'test element node with dynamic value': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')

    context = new Wingman.Object
    context.set name: 'Rasmus'
    interpreter = new NodeInterpreter node_data, [], context

    @assert_equal 'Rasmus', interpreter.element.innerHTML

  'test element node with dynamic value and defered update': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')

    context = new Wingman.Object
    context.set name: 'John'
    interpreter = new NodeInterpreter node_data, [], context
    @assert_equal 'John', interpreter.element.innerHTML
    context.set name: 'Rasmus'

    @assert_equal 'Rasmus', interpreter.element.innerHTML

  'test element node with dynamic nested value and defered update': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{user.name}')

    user = new Wingman.Object
    user.set name: 'John'
    context = new Wingman.Object
    context.set {user}
    interpreter = new NodeInterpreter node_data, [], context
    @assert_equal 'John', interpreter.element.innerHTML
    user.set name: 'Rasmus'

    @assert_equal 'Rasmus', interpreter.element.innerHTML

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
    interpreter = new NodeInterpreter node_data, element, context
    
    @assert !interpreter.element
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
    new NodeInterpreter node_data, element, context
    
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
    new NodeInterpreter node_data, element, context
    
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
    new NodeInterpreter node_data, element, context
    
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
    
    interpreter = new NodeInterpreter node_data, []
    
    @assert_equal 'red', interpreter.element.style.color

  'test element node with single dynamic style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new Wingman.Object
    context.set color: 'red'
    interpreter = new NodeInterpreter node_data, [], context
    
    @assert_equal 'red', interpreter.element.style.color

  'test deferred reset with element node with single dynamic style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new Wingman.Object
    context.set color: 'red'
    interpreter = new NodeInterpreter node_data, [], context
    context.set color: 'blue'
    @assert_equal 'blue', interpreter.element.style.color

  'test element node with two static styles': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
        'font-size': new Value('15px')
    
    interpreter = new NodeInterpreter node_data, []
    @assert_equal 'red', interpreter.element.style.color
    @assert_equal '15px', interpreter.element.style.fontSize

  'test element node with two static styles': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{myColor}')
        'font-size': new Value('{myFontSize}')
    
    context = new Wingman.Object

    context.set myColor: 'red', myFontSize: '15px'
    interpreter = new NodeInterpreter node_data, [], context
    style = interpreter.element.style
    @assert_equal 'red', style.color
    @assert_equal '15px', style.fontSize

    context.set myColor: 'blue', myFontSize: '13px'
    @assert_equal 'blue', style.color
    @assert_equal '13px', style.fontSize
