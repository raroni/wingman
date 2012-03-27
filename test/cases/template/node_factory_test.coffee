Janitor = require 'janitor'
NodeFactory = require '../../../lib/wingman/template/node_factory'
Value = require '../../../lib/wingman/template/parser/value'
WingmanObject = require '../../../lib/wingman/shared/object'
Wingman = require '../../..'
CustomAssertions = require '../../custom_assertions'
Wingman.document = require('jsdom').jsdom()

module.exports = class NodeFactoryTest extends Janitor.TestCase
  setup: ->
    @parent = Wingman.document.createElement 'div'
  
  assertDOMElementHasClass: CustomAssertions.assertDOMElementHasClass
  refuteDOMElementHasClass: CustomAssertions.refuteDOMElementHasClass
  
  'test simple element node': ->
    nodeData = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
    
    NodeFactory.create nodeData, @parent
    element = @parent.childNodes[0]
    @assert element
    @assertEqual 'DIV', element.tagName
    @assertEqual @parent, element.parentNode
  
  'test nested element nodes': ->
    nodeData = 
      type: 'element'
      tag: 'div'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('test')
      ]
  
    NodeFactory.create nodeData, @parent
    element = @parent.childNodes[0]
    @assert element
    @assertEqual 'DIV', element.tagName
    @assertEqual 1, element.childNodes.length
    @assertEqual 'SPAN', element.childNodes[0].tagName
    @assertEqual 'test', element.childNodes[0].innerHTML
  
  'test element node with dynamic value': ->
    nodeData = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')
  
    context = new WingmanObject
    context.set name: 'Rasmus'
    NodeFactory.create nodeData, @parent, context
  
    @assertEqual 'Rasmus', @parent.childNodes[0].innerHTML
  
  'test element node with dynamic value and defered update': ->
    nodeData = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')
  
    context = new WingmanObject
    context.set name: 'John'
    NodeFactory.create nodeData, @parent, context
    element = @parent.childNodes[0]
    @assertEqual 'John', element.innerHTML
    context.set name: 'Rasmus'
  
    @assertEqual 'Rasmus', element.innerHTML
  
  'test element node with dynamic nested value and defered update': ->
    nodeData = 
      type: 'element'
      tag: 'div'
      value: new Value('{user.name}')
  
    user = new WingmanObject
    user.set name: 'John'
    context = new WingmanObject
    context.set {user}
    NodeFactory.create nodeData, @parent, context
    element = @parent.childNodes[0]
    @assertEqual 'John', element.innerHTML
    user.set name: 'Rasmus'
  
    @assertEqual 'Rasmus', element.innerHTML
  
  'test for node': ->
    nodeData =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'li'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
  
    NodeFactory.create nodeData, @parent, context
    childNodes = @parent.childNodes
    @assertEqual 2, childNodes.length
    @assertEqual 'Rasmus', childNodes[0].innerHTML
    @assertEqual 'John', childNodes[1].innerHTML
  
  'test for node with deferred push': ->
    nodeData =
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
    NodeFactory.create nodeData, element, context
    
    @assertEqual 2, element.childNodes.length
    context.get('users').push 'Joe'
    @assertEqual 3, element.childNodes.length
    @assertEqual 'Joe', element.childNodes[2].innerHTML
  
  'test for node with deferred remove': ->
    nodeData =
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
    NodeFactory.create nodeData, element, context
    
    @assertEqual 2, element.childNodes.length
    context.get('users').remove 'John'
    @assertEqual 1, element.childNodes.length
  
  'test for node with deferred reset': ->
    nodeData =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
  
    NodeFactory.create nodeData, @parent, context
    
    @assertEqual 2, @parent.childNodes.length
    context.set users: ['Oliver']
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'Oliver', @parent.childNodes[0].innerHTML
  
  'test element node with single static style': ->
    nodeData = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
    
    NodeFactory.create nodeData, @parent
    @assertEqual 'red', @parent.childNodes[0].style.color
  
  'test element node with single dynamic style': ->
    nodeData = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new WingmanObject
    context.set color: 'red'
    
    NodeFactory.create nodeData, @parent, context
    
    @assertEqual 'red', @parent.childNodes[0].style.color
  
  'test deferred reset with element node with single dynamic style': ->
    nodeData = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new WingmanObject
    context.set color: 'red'
    NodeFactory.create nodeData, @parent, context
    context.set color: 'blue'
    @assertEqual 'blue', @parent.childNodes[0].style.color
  
  'test element node with two static styles': ->
    nodeData = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
        'font-size': new Value('15px')
    
    NodeFactory.create nodeData, @parent
    element = @parent.childNodes[0]
    @assertEqual 'red', element.style.color
    @assertEqual '15px', element.style.fontSize
  
  'test element node with two static styles': ->
    nodeData = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{myColor}')
        'font-size': new Value('{myFontSize}')
    
    context = new WingmanObject
  
    context.set myColor: 'red', myFontSize: '15px'
    NodeFactory.create nodeData, @parent, context
    style = @parent.childNodes[0].style
    @assertEqual 'red', style.color
    @assertEqual '15px', style.fontSize
  
    context.set myColor: 'blue', myFontSize: '13px'
    @assertEqual 'blue', style.color
    @assertEqual '13px', style.fontSize
  
  'test element node with two dynamic styles': ->
    nodeData = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{myColor}')
        'font-size': new Value('{myFontSize}')
    
    context = new WingmanObject
    context.set myColor: 'red', myFontSize: '15px'
    NodeFactory.create nodeData, @parent, context
    
    element = @parent.childNodes[0]
    @assertEqual 'red', element.style.color
    @assertEqual '15px', element.style.fontSize
  
    context.set myColor: 'blue', myFontSize: '13px'
    @assertEqual 'blue', element.style.color
    @assertEqual '13px', element.style.fontSize
  
  'test element node with single static class': ->
    nodeData =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('user')]
    
    NodeFactory.create nodeData, @parent
    @assertEqual @parent.childNodes[0].className, 'user'
  
  'test element node with two static classes': ->
    nodeData =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('user'), new Value('premium')]
    
    NodeFactory.create nodeData, @parent
    element = @parent.childNodes[0]
    @assertDOMElementHasClass element, 'user'
    @assertDOMElementHasClass element, 'premium'
  
  'test element node with single dynamic class': ->
    nodeData =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    NodeFactory.create nodeData, @parent, context
    @assertDOMElementHasClass @parent.childNodes[0], 'user'
  
  'test deferred reset with element node with single dynamic class': ->
    nodeData =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    NodeFactory.create nodeData, @parent, context
    element = @parent.childNodes[0]
    @assertEqual element.className, 'user'
    context.set myAwesomeClass: 'something_else'
    @assertEqual element.className, 'something_else'
  
  'test deferred reset to falsy value with element node with single dynamic class': ->
    nodeData =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    NodeFactory.create nodeData, @parent, context
    element = @parent.childNodes[0]
    @assertEqual element.className, 'user'
    context.set myAwesomeClass: null
    @assertEqual element.className, ''
  
  'test element node with two dynamic classes that evaluates to the same value': ->
    elementNode =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [
        new Value('{myAwesomeClass}'),
        new Value('{mySuperbClass}')
      ]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user', mySuperbClass: 'user'
  
    NodeFactory.create elementNode, @parent, context
    @assertEqual @parent.childNodes[0].className, 'user'
  
  'test deferred reset of dynamic class that evaluates to the same value as another dynamic class in node element': ->
    elementNode =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [
        new Value('{myAwesomeClass}'),
        new Value('{mySuperbClass}')
      ]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user', mySuperbClass: 'user'
  
    NodeFactory.create elementNode, @parent, context
    context.set myAwesomeClass: 'premium'
    
    element = @parent.childNodes[0]
    @assertDOMElementHasClass element, 'user'
    @assertDOMElementHasClass element, 'premium'
  
  'test child view': ->
    elementNode =
      type: 'childView'
      name: 'user'
    
    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: -> '<div>I am the user view</div>'
    
    mainView = new MainView
    NodeFactory.create elementNode, @parent, mainView
    @assertEqual '<div>I am the user view</div>', @parent.childNodes[0].innerHTML
  
  'test conditional': ->
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
    NodeFactory.create nodeData, @parent, context
    
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
    NodeFactory.create nodeData, @parent, context
    
    childNodes = @parent.childNodes
    @assertEqual 2, childNodes.length
    @assertEqual 'good morning', childNodes[0].innerHTML
    @assertEqual 'good morning again', childNodes[1].innerHTML
    context.set early: false
    @assertEqual 1, childNodes.length
    @assertEqual 'good evening', childNodes[0].innerHTML
