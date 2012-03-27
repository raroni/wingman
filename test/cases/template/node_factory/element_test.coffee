Janitor = require 'janitor'
Value = require '../../../../lib/wingman/template/parser/value'
Element = require '../../../../lib/wingman/template/node_factory/element'
Wingman = require '../../../../.'
WingmanObject = require '../../../../lib/wingman/shared/object'
CustomAssertions = require '../../../custom_assertions'
Wingman.document = require('jsdom').jsdom()

module.exports = class ElementTest extends Janitor.TestCase
  setup: ->
    @parent = Wingman.document.createElement 'div'
  
  assertDOMElementHasClass: CustomAssertions.assertDOMElementHasClass
  refuteDOMElementHasClass: CustomAssertions.refuteDOMElementHasClass
  
  'test simple element': ->
    elementNode =
      type: 'element'
      tag: 'div'
      value: new Value('test')
    
    element = new Element elementNode, @parent
    @assert element.domElement
    @assertEqual 'DIV', element.domElement.tagName
    @assertEqual @parent, element.domElement.parentNode
  
  'test nested elements': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('test')
      ]
  
    element = new Element elementNode, @parent
    @assert element.domElement
    @assertEqual 'DIV', element.domElement.tagName
    @assertEqual 1, element.domElement.childNodes.length
    @assertEqual 'SPAN', element.domElement.childNodes[0].tagName
    @assertEqual 'test', element.domElement.childNodes[0].innerHTML
  
  'test element with dynamic value': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')
  
    context = new WingmanObject
    context.set name: 'Rasmus'
    element = new Element elementNode, @parent, context
  
    @assertEqual 'Rasmus', element.domElement.innerHTML
  
  'test element with dynamic value and defered update': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')
  
    context = new WingmanObject
    context.set name: 'John'
    element = new Element elementNode, @parent, context
    @assertEqual 'John', element.domElement.innerHTML
    context.set name: 'Rasmus'
  
    @assertEqual 'Rasmus', element.domElement.innerHTML
  
  'test element with dynamic nested value and defered update': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      value: new Value('{user.name}')
  
    user = new WingmanObject
    user.set name: 'John'
    context = new WingmanObject
    context.set {user}
    element = new Element elementNode, @parent, context
    @assertEqual 'John', element.domElement.innerHTML
    user.set name: 'Rasmus'
  
    @assertEqual 'Rasmus', element.domElement.innerHTML
  
  'test element with single static style': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
    
    element = new Element elementNode, @parent
    
    @assertEqual 'red', element.domElement.style.color
  
  'test element with single dynamic style': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new WingmanObject
    context.set color: 'red'
    element = new Element elementNode, @parent, context
    
    @assertEqual 'red', element.domElement.style.color
  
  'test deferred reset with element with single dynamic style': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new WingmanObject
    context.set color: 'red'
    element = new Element elementNode, @parent, context
    context.set color: 'blue'
    @assertEqual 'blue', element.domElement.style.color
  
  'test element with two static styles': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
        'font-size': new Value('15px')
    
    element = new Element elementNode, @parent
    
    @assertEqual 'red', element.domElement.style.color
    @assertEqual '15px', element.domElement.style.fontSize
  
  'test element with two dynamic styles': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{myColor}')
        'font-size': new Value('{myFontSize}')
    
    context = new WingmanObject
    context.set myColor: 'red', myFontSize: '15px'
    element = new Element elementNode, @parent, context
  
    @assertEqual 'red', element.domElement.style.color
    @assertEqual '15px', element.domElement.style.fontSize
  
    context.set myColor: 'blue', myFontSize: '13px'
    @assertEqual 'blue', element.domElement.style.color
    @assertEqual '13px', element.domElement.style.fontSize
  
  'test element with single static class': ->
    elementNode =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('user')]
    
    element = new Element elementNode, @parent
    @assertEqual element.domElement.className, 'user'
  
  'test element with two static classes': ->
    elementNode =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('user'), new Value('premium')]
    
    element = new Element elementNode, @parent
    @assertDOMElementHasClass element.domElement, 'user'
    @assertDOMElementHasClass element.domElement, 'premium'
  
  'test element with single dynamic class': ->
    elementNode =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    element = new Element elementNode, @parent, context
    @assertDOMElementHasClass element.domElement, 'user'
  
  'test deferred reset with element with single dynamic class': ->
    elementNode =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    element = new Element elementNode, @parent, context
    @assertEqual element.domElement.className, 'user'
    context.set myAwesomeClass: 'something_else'
    @assertEqual element.domElement.className, 'something_else'
  
  'test deferred reset to falsy value with element with single dynamic class': ->
    elementNode =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    element = new Element elementNode, @parent, context
    @assertEqual element.domElement.className, 'user'
    context.set myAwesomeClass: null
    @assertEqual element.domElement.className, ''
  
  'test element with two dynamic classes that evaluates to the same value': ->
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
  
    element = new Element elementNode, @parent, context
    @assertEqual element.domElement.className, 'user'
  
  'test deferred reset of dynamic class that evaluates to the same value as another dynamic class': ->
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
    
    element = new Element elementNode, @parent, context
    context.set myAwesomeClass: 'premium'
    
    @assertDOMElementHasClass element.domElement, 'user'
    @assertDOMElementHasClass element.domElement, 'premium'
  
  'test regular attributes': ->
    elementNode =
      type: 'element'
      tag: 'input'
      attributes:
        name: new Value('email')
        placeholder: new Value('Email...')
    
    element = new Element(elementNode, @parent).domElement
    @assertEqual 'email', element.getAttribute('name')
    @assertEqual 'Email...', element.getAttribute('placeholder')
  
  'test regular attributes with a dynamic value': ->
    elementNode =
      type: 'element'
      tag: 'img'
      attributes:
        src: new Value('{mySrc}')
    
    context = new WingmanObject
    context.set mySrc: 'funny_pic.png'
    
    element = new Element(elementNode, @parent, context).domElement
    @assertEqual 'funny_pic.png', element.getAttribute('src')
    context.set mySrc: 'funny_pic2.png'
    @assertEqual 'funny_pic2.png', element.getAttribute('src')
