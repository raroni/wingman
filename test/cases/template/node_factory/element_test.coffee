Janitor = require 'janitor'
Element = require '../../../../lib/wingman/template/node_factory/element'
Wingman = require '../../../../.'
WingmanObject = require '../../../../lib/wingman/shared/object'
CustomAssertions = require '../../../custom_assertions'
jsdom = require 'jsdom'

module.exports = class ElementTest extends Janitor.TestCase
  setup: ->
    Wingman.document = jsdom.jsdom()
    @parent = Wingman.document.createElement 'div'
  
  teardown: ->
    delete Wingman.document
  
  assertDOMElementHasClass: CustomAssertions.assertDOMElementHasClass
  refuteDOMElementHasClass: CustomAssertions.refuteDOMElementHasClass
  
  'test simple element': ->
    elementNode =
      type: 'element'
      tag: 'div'
      children: []
    
    element = new Element elementNode, @parent
    @assert element.domElement
    @assertEqual 'DIV', element.domElement.tagName
    @assertEqual @parent, element.domElement.parentNode
  
  'test element with text': ->
    elementNode =
      type: 'element'
      tag: 'div'
      children: [
        type: 'text'
        value: 'test'
      ]
    
    element = new Element elementNode, @parent
    @assert element.domElement
    @assertEqual 'test', element.domElement.innerHTML
  
  'test nested elements': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      children: [
        type: 'element'
        tag: 'span'
        children: [
          type: 'text'
          value: 'test'
        ]
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
      source: 'name'
    
    context = new WingmanObject
    context.set name: 'Rasmus'
    element = new Element elementNode, @parent, context
  
    @assertEqual 'Rasmus', element.domElement.innerHTML
  
  'test element with dynamic value and defered update': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      source: 'name'
    
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
      source: 'user.name'
    
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
      children: [
        type: 'text'
        value: 'test'
      ]
      styles:
        color:
          type: 'text'
          value: 'red'
    
    element = new Element elementNode, @parent
    
    @assertEqual 'red', element.domElement.style.color
  
  'test element with single dynamic style': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      children: [
        text: 'test'
        type: 'text'
      ]
      styles:
        color:
          type: 'text'
          value: 'color'
          isDynamic: true
    
    context = new WingmanObject
    context.set color: 'red'
    element = new Element elementNode, @parent, context
    
    @assertEqual 'red', element.domElement.style.color
  
  'test deferred reset with element with single dynamic style': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      children: [
        text: 'test'
        type: 'text'
      ]
      styles:
        color:
          type: 'text'
          value: 'color'
          isDynamic: true
    
    context = new WingmanObject
    context.set color: 'red'
    element = new Element elementNode, @parent, context
    context.set color: 'blue'
    @assertEqual 'blue', element.domElement.style.color
  
  'test element with two static styles': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      children: [
        type: 'text'
        value: 'test'
      ]
      styles:
        color:
          type: 'text'
          value: 'red'
        'font-size':
          type: 'text'
          value: '15px'
    
    element = new Element elementNode, @parent
    
    @assertEqual 'red', element.domElement.style.color
    @assertEqual '15px', element.domElement.style.fontSize
  
  'test element with two dynamic styles': ->
    elementNode = 
      type: 'element'
      tag: 'div'
      styles:
        color:
          type: 'text'
          value: 'myColor'
          isDynamic: true
        'font-size':
          type: 'text'
          value: 'myFontSize'
          isDynamic: true
    
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
      classes: [
        type: 'text'
        value: 'user'
      ]
    
    element = new Element elementNode, @parent
    @assertEqual element.domElement.className, 'user'
  
  'test element with two static classes': ->
    elementNode =
      type: 'element'
      tag: 'div'
      classes: [
        {
          type: 'text'
          value: 'user'
        }
        {
          type: 'text'
          value: 'premium'
        }
      ]
    
    element = new Element elementNode, @parent
    @assertDOMElementHasClass element.domElement, 'user'
    @assertDOMElementHasClass element.domElement, 'premium'
  
  'test element with single dynamic class': ->
    elementNode =
      type: 'element'
      tag: 'div'
      classes: [
        type: 'text'
        value: 'myAwesomeClass'
        isDynamic: true
      ]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    element = new Element elementNode, @parent, context
    @assertDOMElementHasClass element.domElement, 'user'
  
  'test deferred reset with element with single dynamic class': ->
    elementNode =
      type: 'element'
      tag: 'div'
      classes: [
        type: 'text'
        value: 'myAwesomeClass'
        isDynamic: true
      ]
    
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
      classes: [
        type: 'text'
        value: 'myAwesomeClass'
        isDynamic: true
      ]
    
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
      classes: [
        {
          type: 'text'
          value: 'myAwesomeClass'
          isDynamic: true
        }
        {
          type: 'text'
          value: 'mySuperbClass'
          isDynamic: true
        }
      ]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user', mySuperbClass: 'user'
  
    element = new Element elementNode, @parent, context
    @assertEqual element.domElement.className, 'user'
  
  'test deferred reset of dynamic class that evaluates to the same value as another dynamic class': ->
    elementNode =
      type: 'element'
      tag: 'div'
      classes: [
        {
          type: 'text'
          value: 'myAwesomeClass'
          isDynamic: true
        }
        {
          type: 'text'
          value: 'mySuperbClass'
          isDynamic: true
        }
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
        name:
          type: 'text'
          value: 'email'
        placeholder:
          type: 'text'
          value: 'Email...'
    
    element = new Element(elementNode, @parent).domElement
    @assertEqual 'email', element.getAttribute('name')
    @assertEqual 'Email...', element.getAttribute('placeholder')
  
  'test regular attributes with a dynamic value': ->
    elementNode =
      type: 'element'
      tag: 'img'
      attributes:
        src:
          type: 'text'
          value: 'mySrc'
          isDynamic: true
    
    context = new WingmanObject
    context.set mySrc: 'funny_pic.png'
    
    element = new Element(elementNode, @parent, context).domElement
    @assertEqual 'funny_pic.png', element.getAttribute('src')
    context.set mySrc: 'funny_pic2.png'
    @assertEqual 'funny_pic2.png', element.getAttribute('src')
  
  'test dynamic and static class': ->
    elementNode =
      type: 'element'
      tag: 'div'
      classes: [
        {
          type: 'text'
          value: 'user'
        }
        {
          type: 'text'
          value: 'selectedCls'
          isDynamic: true
        }
      ]
    
    context = new WingmanObject
    context.set selectedCls: 'selected'
    element = new Element(elementNode, @parent, context).domElement
    
    @assertDOMElementHasClass element, 'user'
    @assertDOMElementHasClass element, 'selected'
  
  'test deactivated dynamic class when also having static class': ->
    elementNode =
      type: 'element'
      tag: 'div'
      classes: [
        {
          type: 'text'
          value: 'user'
        }
        {
          type: 'text'
          value: 'selectedCls'
          isDynamic: true
        }
      ]
    
    context = new WingmanObject
    context.set selectedCls: undefined
    element = new Element(elementNode, @parent, context).domElement
    
    element = @parent.childNodes[0]
    @assertEqual 'user', element.className
  
  'test deferred deactivation of dynamic class when also having static class': ->
    elementNode =
      type: 'element'
      tag: 'div'
      classes: [
        {
          type: 'text'
          value: 'user'
        }
        {
          type: 'text'
          value: 'selectedCls'
          isDynamic: true
        }
      ]
    
    context = new WingmanObject
    context.set selectedCls: 'selected'
    
    element = new Element(elementNode, @parent, context).domElement
    
    context.set selectedCls: undefined
    @assertEqual 'user', element.className
