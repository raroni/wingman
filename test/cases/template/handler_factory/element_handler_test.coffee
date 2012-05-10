Janitor = require 'janitor'
ElementHandler = require '../../../../lib/wingman/template/handler_factory/element_handler'
Wingman = require '../../../../.'
CustomAssertions = require '../../../custom_assertions'
jsdom = require 'jsdom'

module.exports = class ElementHandlerTest extends Janitor.TestCase
  setup: ->
    Wingman.document = jsdom.jsdom()
    @parent = Wingman.document.createElement 'div'
  
  teardown: ->
    delete Wingman.document
  
  assertDOMElementHasClass: CustomAssertions.assertDOMElementHasClass
  refuteDOMElementHasClass: CustomAssertions.refuteDOMElementHasClass
  
  'test simple element': ->
    options =
      tag: 'div'
      children: []
      scope: @parent
      
    element = new ElementHandler options
    @assert element.el
    @assertEqual 'DIV', element.el.tagName
    @assertEqual @parent, element.el.parentNode
  
  'test element with text': ->
    options =
      tag: 'div'
      children: [
        type: 'text'
        value: 'test'
      ]
      scope: @parent
    
    element = new ElementHandler options
    @assert element.el
    @assertEqual 'test', element.el.innerHTML
  
  'test nested elements': ->
    options =
      scope: @parent
      tag: 'div'
      children: [
        type: 'element'
        tag: 'span'
        children: [
          type: 'text'
          value: 'test'
        ]
      ]
    
    element = new ElementHandler options
    @assert element.el
    @assertEqual 'DIV', element.el.tagName
    @assertEqual 1, element.el.childNodes.length
    @assertEqual 'SPAN', element.el.childNodes[0].tagName
    @assertEqual 'test', element.el.childNodes[0].innerHTML
  
  'test element with dynamic value': ->
    options = 
      tag: 'div'
      source: 'name'
      scope: @parent
    
    Context = Wingman.Object.extend name: null
    context = new Context
    context.name = 'Rasmus'
    element = new ElementHandler options, context
    @assertEqual 'Rasmus', element.el.innerHTML
  
  'test element with dynamic value and defered update': ->
    options = 
      tag: 'div'
      source: 'name'
      scope: @parent
    
    Context = Wingman.Object.extend name: null
    context = new Context
    context.name = 'John'
    element = new ElementHandler options, context
    @assertEqual 'John', element.el.innerHTML
    context.name = 'Rasmus'
    @assertEqual 'Rasmus', element.el.innerHTML
  
  'test element with dynamic nested value and defered update': ->
    options = 
      tag: 'div'
      source: 'user.name'
      scope: @parent
    
    User = Wingman.Object.extend name: null
    user = new User
    user.name = 'John'
    Context = Wingman.Object.extend user: null
    context = new Context
    context.user = user
    element = new ElementHandler options, context
    
    @assertEqual 'John', element.el.innerHTML
    
    user.name = 'Rasmus'
    @assertEqual 'Rasmus', element.el.innerHTML
  
  'test element with single static style': ->
    options = 
      tag: 'div'
      scope: @parent
      children: [
        type: 'text'
        value: 'test'
      ]
      styles:
        color:
          type: 'text'
          value: 'red'
    
    element = new ElementHandler options
    
    @assertEqual 'red', element.el.style.color
  
  'test element with single dynamic style': ->
    options = 
      tag: 'div'
      scope: @parent
      children: [
        text: 'test'
        type: 'text'
      ]
      styles:
        color:
          type: 'text'
          value: 'color'
          isDynamic: true
    
    Context = Wingman.Object.extend color: null
    context = new Context
    context.color = 'red'
    handler = new ElementHandler options, context
    @assertEqual 'red', handler.el.style.color
  
  'test deferred reset with element with single dynamic style': ->
    options = 
      tag: 'div'
      scope: @parent
      children: [
        text: 'test'
        type: 'text'
      ]
      styles:
        color:
          type: 'text'
          value: 'color'
          isDynamic: true
    
    Context = Wingman.Object.extend color: null
    context = new Context
    context.color = 'red'
    element = new ElementHandler options, context
    context.color = 'blue'
    @assertEqual 'blue', element.el.style.color
  
  'test element with two static styles': ->
    options = 
      tag: 'div'
      scope: @parent
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
    
    element = new ElementHandler options
    
    @assertEqual 'red', element.el.style.color
    @assertEqual '15px', element.el.style.fontSize
  
  'test element with two dynamic styles': ->
    options = 
      tag: 'div'
      scope: @parent
      styles:
        color:
          type: 'text'
          value: 'myColor'
          isDynamic: true
        'font-size':
          type: 'text'
          value: 'myFontSize'
          isDynamic: true
    
    Context = Wingman.Object.extend myColor: null, myFontSize: null
    context = new Context
    context.set myColor: 'red', myFontSize: '15px'
    element = new ElementHandler options, context
    
    @assertEqual 'red', element.el.style.color
    @assertEqual '15px', element.el.style.fontSize
    
    context.set myColor: 'blue', myFontSize: '13px'
    @assertEqual 'blue', element.el.style.color
    @assertEqual '13px', element.el.style.fontSize
  
  'test element with single static class': ->
    options =
      tag: 'div'
      scope: @parent
      classes: [
        type: 'text'
        value: 'user'
      ]
    
    element = new ElementHandler options
    @assertEqual element.el.className, 'user'
  
  'test element with two static classes': ->
    options =
      tag: 'div'
      scope: @parent
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
    
    element = new ElementHandler options
    @assertDOMElementHasClass element.el, 'user'
    @assertDOMElementHasClass element.el, 'premium'
  
  'test element with single dynamic class': ->
    options =
      tag: 'div'
      scope: @parent
      classes: [
        type: 'text'
        value: 'myAwesomeClass'
        isDynamic: true
      ]
    
    Context = Wingman.Object.extend myAwesomeClass: null
    context = new Context
    context.myAwesomeClass = 'user'
    element = new ElementHandler options, context
    @assertDOMElementHasClass element.el, 'user'
  
  'test deferred reset with element with single dynamic class': ->
    options =
      tag: 'div'
      scope: @parent
      classes: [
        type: 'text'
        value: 'myAwesomeClass'
        isDynamic: true
      ]
    
    Context = Wingman.Object.extend myAwesomeClass: null
    context = new Context
    context.myAwesomeClass = 'user'
    element = new ElementHandler options, context
    
    @assertEqual element.el.className, 'user'
    
    context.myAwesomeClass = 'something_else'
    @assertEqual element.el.className, 'something_else'
  
  'test deferred reset to falsy value with element with single dynamic class': ->
    options =
      tag: 'div'
      scope: @parent
      classes: [
        type: 'text'
        value: 'myAwesomeClass'
        isDynamic: true
      ]
    
    Context = Wingman.Object.extend myAwesomeClass: null
    context = new Context
    context.myAwesomeClass = 'user'
    element = new ElementHandler options, context
    
    @assertEqual element.el.className, 'user'
    
    context.myAwesomeClass = null
    @assertEqual element.el.className, ''
  
  'test element with two dynamic classes that evaluates to the same value': ->
    options =
      tag: 'div'
      scope: @parent
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
    
    Context = Wingman.Object.extend myAwesomeClass: null, mySuperbClass: null
    context = new Context
    context.set myAwesomeClass: 'user', mySuperbClass: 'user'
    element = new ElementHandler options, context
    
    @assertEqual element.el.className, 'user'
  
  'test deferred reset of dynamic class that evaluates to the same value as another dynamic class': ->
    options =
      tag: 'div'
      scope: @parent
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
    
    Context = Wingman.Object.extend myAwesomeClass: null, mySuperbClass: null
    context = new Context
    context.set myAwesomeClass: 'user', mySuperbClass: 'user'
    element = new ElementHandler options, context
    context.myAwesomeClass = 'premium'
    
    @assertDOMElementHasClass element.el, 'user'
    @assertDOMElementHasClass element.el, 'premium'
  
  'test regular attributes': ->
    options =
      tag: 'input'
      scope: @parent
      attributes:
        name:
          type: 'text'
          value: 'email'
        placeholder:
          type: 'text'
          value: 'Email...'
    
    element = new ElementHandler(options).el
    @assertEqual 'email', element.getAttribute('name')
    @assertEqual 'Email...', element.getAttribute('placeholder')
  
  'test regular attributes with a dynamic value': ->
    options =
      tag: 'img'
      scope: @parent
      attributes:
        src:
          type: 'text'
          value: 'mySrc'
          isDynamic: true
    
    Context = Wingman.Object.extend mySrc: null
    context = new Context
    context.mySrc = 'funny_pic.png'
    element = new ElementHandler(options, context).el
    
    @assertEqual 'funny_pic.png', element.getAttribute('src')
    
    context.mySrc = 'funny_pic2.png'
    @assertEqual 'funny_pic2.png', element.getAttribute('src')
  
  'test dynamic and static class': ->
    options =
      tag: 'div'
      scope: @parent
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
    
    Context = Wingman.Object.extend selectedCls: null
    context = new Context
    context.selectedCls = 'selected'
    element = new ElementHandler(options, context).el
    
    @assertDOMElementHasClass element, 'user'
    @assertDOMElementHasClass element, 'selected'
  
  'test deactivated dynamic class when also having static class': ->
    options =
      tag: 'div'
      scope: @parent
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
    
    Context = Wingman.Object.extend selectedCls: null
    context = new Context
    context.selectedCls = undefined
    element = new ElementHandler(options, context).el
    
    element = @parent.childNodes[0]
    @assertEqual 'user', element.className
  
  'test deferred deactivation of dynamic class when also having static class': ->
    options =
      tag: 'div'
      scope: @parent
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
    
    Context = Wingman.Object.extend selectedCls: null
    context = new Context
    context.selectedCls = 'selected'
    element = new ElementHandler(options, context).el
    
    context.selectedCls = undefined
    @assertEqual 'user', element.className
  
  'test passing element': ->
    element = Wingman.document.createElement('div')
    options =
      el: element
      children: []
    
    handler = new ElementHandler options
    @assert handler.el
    @assertEqual element, handler.el
