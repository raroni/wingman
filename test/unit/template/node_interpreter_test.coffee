Janitor = require 'janitor'
NodeInterpreter = require '../../../lib/wingman/template/node_interpreter'
Value = require '../../../lib/wingman/template/parser/value'
WingmanObject = require '../../../lib/wingman/shared/object'
Wingman = require '../../..'
document = require('jsdom').jsdom()
CustomAssertions = require '../../custom_assertions'

module.exports = class extends Janitor.TestCase
  setup: ->
    Wingman.document = document
  
  assertDOMElementHasClass: CustomAssertions.assertDOMElementHasClass
  refuteDOMElementHasClass: CustomAssertions.refuteDOMElementHasClass
  
  'test simple element node': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')

    scope = []
    interpreter = new NodeInterpreter node_data, scope
    @assert interpreter.element
    @assertEqual 'DIV', interpreter.element.tagName

  'test simple element node in dom scope': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')

    scope = document.createElement 'li'
    interpreter = new NodeInterpreter node_data, scope

    @assert interpreter.element
    @assertEqual 'DIV', interpreter.element.tagName
    @assertEqual 'LI', interpreter.element.parentNode.tagName

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
    @assertEqual 'DIV', interpreter.element.tagName
    @assertEqual 1, interpreter.element.childNodes.length
    @assertEqual 'SPAN', interpreter.element.childNodes[0].tagName
    @assertEqual 'test', interpreter.element.childNodes[0].innerHTML

  'test element node with dynamic value': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')

    context = new WingmanObject
    context.set name: 'Rasmus'
    interpreter = new NodeInterpreter node_data, [], context

    @assertEqual 'Rasmus', interpreter.element.innerHTML

  'test element node with dynamic value and defered update': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')

    context = new WingmanObject
    context.set name: 'John'
    interpreter = new NodeInterpreter node_data, [], context
    @assertEqual 'John', interpreter.element.innerHTML
    context.set name: 'Rasmus'

    @assertEqual 'Rasmus', interpreter.element.innerHTML

  'test element node with dynamic nested value and defered update': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{user.name}')

    user = new WingmanObject
    user.set name: 'John'
    context = new WingmanObject
    context.set {user}
    interpreter = new NodeInterpreter node_data, [], context
    @assertEqual 'John', interpreter.element.innerHTML
    user.set name: 'Rasmus'

    @assertEqual 'Rasmus', interpreter.element.innerHTML

  'test for node': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'li'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']

    element = document.createElement 'ol'
    interpreter = new NodeInterpreter node_data, element, context
    
    @assert !interpreter.element
    @assertEqual 2, element.childNodes.length
    @assertEqual 'Rasmus', element.childNodes[0].innerHTML
    @assertEqual 'John', element.childNodes[1].innerHTML

  'test for node with deferred push': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'li'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']

    element = document.createElement 'ol'
    new NodeInterpreter node_data, element, context
    
    @assertEqual 2, element.childNodes.length
    context.get('users').push 'Joe'
    @assertEqual 3, element.childNodes.length
    @assertEqual 'Joe', element.childNodes[2].innerHTML
  
  'test for node with deferred remove': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'li'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']

    element = document.createElement 'ol'
    new NodeInterpreter node_data, element, context
    
    @assertEqual 2, element.childNodes.length
    context.get('users').remove 'John'
    @assertEqual 1, element.childNodes.length

  'test for node with deferred reset': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'li'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']

    element = document.createElement 'ol'
    new NodeInterpreter node_data, element, context
    
    @assertEqual 2, element.childNodes.length
    context.set users: ['Oliver']
    @assertEqual 1, element.childNodes.length
    @assertEqual 'Oliver', element.childNodes[0].innerHTML

  'test element node with single static style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
    
    interpreter = new NodeInterpreter node_data, []
    
    @assertEqual 'red', interpreter.element.style.color

  'test element node with single dynamic style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new WingmanObject
    context.set color: 'red'
    interpreter = new NodeInterpreter node_data, [], context
    
    @assertEqual 'red', interpreter.element.style.color

  'test deferred reset with element node with single dynamic style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new WingmanObject
    context.set color: 'red'
    interpreter = new NodeInterpreter node_data, [], context
    context.set color: 'blue'
    @assertEqual 'blue', interpreter.element.style.color

  'test element node with two static styles': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
        'font-size': new Value('15px')
    
    interpreter = new NodeInterpreter node_data, []
    @assertEqual 'red', interpreter.element.style.color
    @assertEqual '15px', interpreter.element.style.fontSize

  'test element node with two static styles': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{myColor}')
        'font-size': new Value('{myFontSize}')
    
    context = new WingmanObject

    context.set myColor: 'red', myFontSize: '15px'
    interpreter = new NodeInterpreter node_data, [], context
    style = interpreter.element.style
    @assertEqual 'red', style.color
    @assertEqual '15px', style.fontSize

    context.set myColor: 'blue', myFontSize: '13px'
    @assertEqual 'blue', style.color
    @assertEqual '13px', style.fontSize

  'test element node with two dynamic styles': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{myColor}')
        'font-size': new Value('{myFontSize}')
    
    context = new WingmanObject
    context.set myColor: 'red', myFontSize: '15px'
    interpreter = new NodeInterpreter node_data, [], context

    @assertEqual 'red', interpreter.element.style.color
    @assertEqual '15px', interpreter.element.style.fontSize

    context.set myColor: 'blue', myFontSize: '13px'
    @assertEqual 'blue', interpreter.element.style.color
    @assertEqual '13px', interpreter.element.style.fontSize
  
  'test element node with single static class': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('user')]
    
    interpreter = new NodeInterpreter node_data, []
    @assertEqual interpreter.element.className, 'user'

  'test element node with two static classes': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('user'), new Value('premium')]
    
    interpreter = new NodeInterpreter node_data, []
    @assertDOMElementHasClass interpreter.element, 'user'
    @assertDOMElementHasClass interpreter.element, 'premium'

  'test element node with single dynamic class': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'

    interpreter = new NodeInterpreter node_data, [], context
    @assertDOMElementHasClass interpreter.element, 'user'

  'test deferred reset with element node with single dynamic class': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'

    interpreter = new NodeInterpreter node_data, [], context
    @assertEqual interpreter.element.className, 'user'
    context.set myAwesomeClass: 'something_else'
    @assertEqual interpreter.element.className, 'something_else'

  'test deferred reset to falsy value with element node with single dynamic class': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'

    interpreter = new NodeInterpreter node_data, [], context
    @assertEqual interpreter.element.className, 'user'
    context.set myAwesomeClass: null
    @assertEqual interpreter.element.className, ''

  'test element node with two dynamic classes that evaluates to the same value': ->
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [
        new Value('{myAwesomeClass}'),
        new Value('{mySuperbClass}')
      ]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user', mySuperbClass: 'user'

    interpreter = new NodeInterpreter element_node, [], context
    @assertEqual interpreter.element.className, 'user'

  'test deferred reset of dynamic class that evaluates to the same value as another dynamic class in node element': ->
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [
        new Value('{myAwesomeClass}'),
        new Value('{mySuperbClass}')
      ]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user', mySuperbClass: 'user'

    interpreter = new NodeInterpreter element_node, [], context
    context.set myAwesomeClass: 'premium'

    @assertDOMElementHasClass interpreter.element, 'user'
    @assertDOMElementHasClass interpreter.element, 'premium'

  'test sub view': ->
    element_node =
      type: 'sub_view'
      name: 'user'

    class UserView extends Wingman.View
      templateSource: -> '<div>test</div>'

    user_view = new UserView
    context = new WingmanObject
    context.set user: user_view
    scope = []
    interpreter = new NodeInterpreter element_node, scope, context
    @assertEqual '<div>test</div>', scope[0].innerHTML
