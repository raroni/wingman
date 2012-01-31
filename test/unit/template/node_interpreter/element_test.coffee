Janitor = require 'janitor'
Value = require '../../../../lib/wingman/template/parser/value'
Element = require '../../../../lib/wingman/template/node_interpreter/element'
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
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('test')
    
    element = new Element element_node, @parent
    @assert element.dom_element
    @assertEqual 'DIV', element.dom_element.tagName
    @assertEqual @parent, element.dom_element.parentNode
  
  'test nested elements': ->
    element_node = 
      type: 'element'
      tag: 'div'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('test')
      ]
  
    element = new Element element_node, @parent
    @assert element.dom_element
    @assertEqual 'DIV', element.dom_element.tagName
    @assertEqual 1, element.dom_element.childNodes.length
    @assertEqual 'SPAN', element.dom_element.childNodes[0].tagName
    @assertEqual 'test', element.dom_element.childNodes[0].innerHTML
  
  'test element with dynamic value': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')
  
    context = new WingmanObject
    context.set name: 'Rasmus'
    element = new Element element_node, @parent, context
  
    @assertEqual 'Rasmus', element.dom_element.innerHTML
  
  'test element with dynamic value and defered update': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')
  
    context = new WingmanObject
    context.set name: 'John'
    element = new Element element_node, @parent, context
    @assertEqual 'John', element.dom_element.innerHTML
    context.set name: 'Rasmus'
  
    @assertEqual 'Rasmus', element.dom_element.innerHTML
  
  'test element with dynamic nested value and defered update': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('{user.name}')
  
    user = new WingmanObject
    user.set name: 'John'
    context = new WingmanObject
    context.set {user}
    element = new Element element_node, @parent, context
    @assertEqual 'John', element.dom_element.innerHTML
    user.set name: 'Rasmus'
  
    @assertEqual 'Rasmus', element.dom_element.innerHTML
  
  'test element with single static style': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
    
    element = new Element element_node, @parent
    
    @assertEqual 'red', element.dom_element.style.color
  
  'test element with single dynamic style': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new WingmanObject
    context.set color: 'red'
    element = new Element element_node, @parent, context
    
    @assertEqual 'red', element.dom_element.style.color
  
  'test deferred reset with element with single dynamic style': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new WingmanObject
    context.set color: 'red'
    element = new Element element_node, @parent, context
    context.set color: 'blue'
    @assertEqual 'blue', element.dom_element.style.color
  
  'test element with two static styles': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
        'font-size': new Value('15px')
    
    element = new Element element_node, @parent
    
    @assertEqual 'red', element.dom_element.style.color
    @assertEqual '15px', element.dom_element.style.fontSize
  
  'test element with two dynamic styles': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{myColor}')
        'font-size': new Value('{myFontSize}')
    
    context = new WingmanObject
    context.set myColor: 'red', myFontSize: '15px'
    element = new Element element_node, @parent, context
  
    @assertEqual 'red', element.dom_element.style.color
    @assertEqual '15px', element.dom_element.style.fontSize
  
    context.set myColor: 'blue', myFontSize: '13px'
    @assertEqual 'blue', element.dom_element.style.color
    @assertEqual '13px', element.dom_element.style.fontSize
  
  'test element with single static class': ->
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('user')]
    
    element = new Element element_node, @parent
    @assertEqual element.dom_element.className, 'user'
  
  'test element with two static classes': ->
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('user'), new Value('premium')]
    
    element = new Element element_node, @parent
    @assertDOMElementHasClass element.dom_element, 'user'
    @assertDOMElementHasClass element.dom_element, 'premium'
  
  'test element with single dynamic class': ->
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    element = new Element element_node, @parent, context
    @assertDOMElementHasClass element.dom_element, 'user'
  
  'test deferred reset with element with single dynamic class': ->
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    element = new Element element_node, @parent, context
    @assertEqual element.dom_element.className, 'user'
    context.set myAwesomeClass: 'something_else'
    @assertEqual element.dom_element.className, 'something_else'
  
  'test deferred reset to falsy value with element with single dynamic class': ->
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    element = new Element element_node, @parent, context
    @assertEqual element.dom_element.className, 'user'
    context.set myAwesomeClass: null
    @assertEqual element.dom_element.className, ''
  
  'test element with two dynamic classes that evaluates to the same value': ->
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
  
    element = new Element element_node, @parent, context
    @assertEqual element.dom_element.className, 'user'
  
  'test deferred reset of dynamic class that evaluates to the same value as another dynamic class': ->
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
    
    element = new Element element_node, @parent, context
    context.set myAwesomeClass: 'premium'
    
    @assertDOMElementHasClass element.dom_element, 'user'
    @assertDOMElementHasClass element.dom_element, 'premium'

  'test regular attributes': ->
    element_node =
      type: 'element'
      tag: 'input'
      attributes:
        name: new Value('email')
        placeholder: new Value('Email...')
    
    element = new Element(element_node, @parent).dom_element
    @assertEqual 'email', element.getAttribute('name')
    @assertEqual 'Email...', element.getAttribute('placeholder')

  'test regular attributes with a dynamic value': ->
    element_node =
      type: 'element'
      tag: 'img'
      attributes:
        src: new Value('{mySrc}')
    
    context = new WingmanObject
    context.set mySrc: 'funny_pic.png'
    
    element = new Element(element_node, @parent, context).dom_element
    @assertEqual 'funny_pic.png', element.getAttribute('src')
    context.set mySrc: 'funny_pic2.png'
    @assertEqual 'funny_pic2.png', element.getAttribute('src')
