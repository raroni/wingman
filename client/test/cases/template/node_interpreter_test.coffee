Janitor = require 'janitor'
NodeInterpreter = require '../../../lib/wingman-client/template/node_interpreter'
Value = require '../../../lib/wingman-client/template/parser/value'
WingmanObject = require '../../../lib/wingman-client/shared/object'
Wingman = require '../../..'
CustomAssertions = require '../../custom_assertions'
Wingman.document = require('jsdom').jsdom()

module.exports = class NodeInterpreterTest extends Janitor.TestCase
  setup: ->
    @parent = Wingman.document.createElement 'div'
  
  assertDOMElementHasClass: CustomAssertions.assertDOMElementHasClass
  refuteDOMElementHasClass: CustomAssertions.refuteDOMElementHasClass
  
  'test simple element node': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
    
    interpreter = new NodeInterpreter node_data, @parent
    element = @parent.childNodes[0]
    @assert element
    @assertEqual 'DIV', element.tagName
    @assertEqual @parent, element.parentNode
  
  'test nested element nodes': ->
    node_data = 
      type: 'element'
      tag: 'div'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('test')
      ]
  
    new NodeInterpreter node_data, @parent
    element = @parent.childNodes[0]
    @assert element
    @assertEqual 'DIV', element.tagName
    @assertEqual 1, element.childNodes.length
    @assertEqual 'SPAN', element.childNodes[0].tagName
    @assertEqual 'test', element.childNodes[0].innerHTML
  
  'test element node with dynamic value': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')
  
    context = new WingmanObject
    context.set name: 'Rasmus'
    new NodeInterpreter node_data, @parent, context
  
    @assertEqual 'Rasmus', @parent.childNodes[0].innerHTML
  
  'test element node with dynamic value and defered update': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')
  
    context = new WingmanObject
    context.set name: 'John'
    new NodeInterpreter node_data, @parent, context
    element = @parent.childNodes[0]
    @assertEqual 'John', element.innerHTML
    context.set name: 'Rasmus'
  
    @assertEqual 'Rasmus', element.innerHTML
  
  'test element node with dynamic nested value and defered update': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{user.name}')
  
    user = new WingmanObject
    user.set name: 'John'
    context = new WingmanObject
    context.set {user}
    new NodeInterpreter node_data, @parent, context
    element = @parent.childNodes[0]
    @assertEqual 'John', element.innerHTML
    user.set name: 'Rasmus'
  
    @assertEqual 'Rasmus', element.innerHTML
  
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
  
    new NodeInterpreter node_data, @parent, context
    child_nodes = @parent.childNodes
    @assertEqual 2, child_nodes.length
    @assertEqual 'Rasmus', child_nodes[0].innerHTML
    @assertEqual 'John', child_nodes[1].innerHTML
  
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
  
    element = Wingman.document.createElement 'ol'
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
  
    element = Wingman.document.createElement 'ol'
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
        tag: 'span'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
  
    new NodeInterpreter node_data, @parent, context
    
    @assertEqual 2, @parent.childNodes.length
    context.set users: ['Oliver']
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'Oliver', @parent.childNodes[0].innerHTML
  
  'test element node with single static style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
    
    new NodeInterpreter node_data, @parent
    @assertEqual 'red', @parent.childNodes[0].style.color
  
  'test element node with single dynamic style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new WingmanObject
    context.set color: 'red'
    
    new NodeInterpreter node_data, @parent, context
    
    @assertEqual 'red', @parent.childNodes[0].style.color
  
  'test deferred reset with element node with single dynamic style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new WingmanObject
    context.set color: 'red'
    new NodeInterpreter node_data, @parent, context
    context.set color: 'blue'
    @assertEqual 'blue', @parent.childNodes[0].style.color
  
  'test element node with two static styles': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
        'font-size': new Value('15px')
    
    new NodeInterpreter node_data, @parent
    element = @parent.childNodes[0]
    @assertEqual 'red', element.style.color
    @assertEqual '15px', element.style.fontSize
  
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
    new NodeInterpreter node_data, @parent, context
    style = @parent.childNodes[0].style
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
    new NodeInterpreter node_data, @parent, context
    
    element = @parent.childNodes[0]
    @assertEqual 'red', element.style.color
    @assertEqual '15px', element.style.fontSize
  
    context.set myColor: 'blue', myFontSize: '13px'
    @assertEqual 'blue', element.style.color
    @assertEqual '13px', element.style.fontSize
  
  'test element node with single static class': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('user')]
    
    new NodeInterpreter node_data, @parent
    @assertEqual @parent.childNodes[0].className, 'user'
  
  'test element node with two static classes': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('user'), new Value('premium')]
    
    new NodeInterpreter node_data, @parent
    element = @parent.childNodes[0]
    @assertDOMElementHasClass element, 'user'
    @assertDOMElementHasClass element, 'premium'
  
  'test element node with single dynamic class': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    new NodeInterpreter node_data, @parent, context
    @assertDOMElementHasClass @parent.childNodes[0], 'user'
  
  'test deferred reset with element node with single dynamic class': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    new NodeInterpreter node_data, @parent, context
    element = @parent.childNodes[0]
    @assertEqual element.className, 'user'
    context.set myAwesomeClass: 'something_else'
    @assertEqual element.className, 'something_else'
  
  'test deferred reset to falsy value with element node with single dynamic class': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    new NodeInterpreter node_data, @parent, context
    element = @parent.childNodes[0]
    @assertEqual element.className, 'user'
    context.set myAwesomeClass: null
    @assertEqual element.className, ''
  
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
  
    new NodeInterpreter element_node, @parent, context
    @assertEqual @parent.childNodes[0].className, 'user'
  
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
  
    interpreter = new NodeInterpreter element_node, @parent, context
    context.set myAwesomeClass: 'premium'
    
    element = @parent.childNodes[0]
    @assertDOMElementHasClass element, 'user'
    @assertDOMElementHasClass element, 'premium'
  
  'test child view': ->
    element_node =
      type: 'child_view'
      name: 'user'
    
    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: -> '<div>I am the user view</div>'
    
    main_view = new MainView
    interpreter = new NodeInterpreter element_node, @parent, main_view
    @assertEqual '<div>I am the user view</div>', @parent.childNodes[0].innerHTML
  
  'test conditonal': ->
    node_data =
      type: 'conditional'
      source: 'something'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('user')
      ]
    
    context = new WingmanObject
    context.set something: true
    new NodeInterpreter node_data, @parent, context
    
    element = @parent.childNodes[0]
    @assert !element.style.display
    
    context.set something: false
    @assertEqual 'none', element.style.display
