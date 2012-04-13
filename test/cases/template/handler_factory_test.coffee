Janitor = require 'janitor'
HandlerFactory = require '../../../lib/wingman/template/handler_factory'
WingmanObject = require '../../../lib/wingman/shared/object'
Wingman = require '../../..'
CustomAssertions = require '../../custom_assertions'
jsdom = require 'jsdom'

module.exports = class HandlerFactoryTest extends Janitor.TestCase
  setup: ->
    Wingman.document = jsdom.jsdom()
    @parent = Wingman.document.createElement 'div'
  
  teardown: ->
    delete Wingman.document
  
  assertDOMElementHasClass: CustomAssertions.assertDOMElementHasClass
  refuteDOMElementHasClass: CustomAssertions.refuteDOMElementHasClass
  
  'test simple element node': ->
    options =
      type: 'element'
      tag: 'div'
      scope: @parent
      children: [
        type: 'text'
        value: 'test'
      ]
    
    HandlerFactory.create options
    element = @parent.childNodes[0]
    @assert element
    @assertEqual 'DIV', element.tagName
    @assertEqual @parent, element.parentNode
  
  'test nested element nodes': ->
    options =
      type: 'element'
      tag: 'div'
      scope: @parent
      children: [
        type: 'element'
        tag: 'span'
        children: [
          type: 'text'
          value: 'test'
        ]
      ]
    
    HandlerFactory.create options
    element = @parent.childNodes[0]
    @assert element
    @assertEqual 'DIV', element.tagName
    @assertEqual 1, element.childNodes.length
    @assertEqual 'SPAN', element.childNodes[0].tagName
    @assertEqual 'test', element.childNodes[0].innerHTML
  
  'test element node with dynamic value': ->
    options =
      type: 'element'
      tag: 'div'
      source: 'name'
      scope: @parent
    
    context = new WingmanObject
    context.set name: 'Rasmus'
    HandlerFactory.create options, context
    
    @assertEqual 'Rasmus', @parent.childNodes[0].innerHTML
  
  'test element node with dynamic value and defered update': ->
    options =
      type: 'element'
      tag: 'div'
      source: 'name'
      scope: @parent
    
    context = new WingmanObject
    context.set name: 'John'
    HandlerFactory.create options, context
    element = @parent.childNodes[0]
    @assertEqual 'John', element.innerHTML
    context.set name: 'Rasmus'
    
    @assertEqual 'Rasmus', element.innerHTML
  
  'test element node with dynamic nested value and defered update': ->
    options =
      type: 'element'
      tag: 'div'
      source: 'user.name'
      scope: @parent
    
    user = new WingmanObject
    user.set name: 'John'
    context = new WingmanObject
    context.set {user}
    HandlerFactory.create options, context
    element = @parent.childNodes[0]
    @assertEqual 'John', element.innerHTML
    user.set name: 'Rasmus'
  
    @assertEqual 'Rasmus', element.innerHTML
  
  'test for node': ->
    options =
      type: 'for'
      source: 'users'
      scope: @parent
      children: [
        type: 'element'
        tag: 'li'
        source: 'user'
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
    
    HandlerFactory.create options, context
    childNodes = @parent.childNodes
    @assertEqual 2, childNodes.length
    @assertEqual 'Rasmus', childNodes[0].innerHTML
    @assertEqual 'John', childNodes[1].innerHTML
  
  'test for node with deferred push': ->
    element = Wingman.document.createElement 'ol'
    options =
      type: 'for'
      source: 'users'
      scope: element
      children: [
        type: 'element'
        tag: 'li'
        source: 'user'
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
    
    HandlerFactory.create options, context
    
    @assertEqual 2, element.childNodes.length
    context.get('users').push 'Joe'
    @assertEqual 3, element.childNodes.length
    @assertEqual 'Joe', element.childNodes[2].innerHTML
  
  'test for node with deferred remove': ->
    element = Wingman.document.createElement 'ol'
    options =
      type: 'for'
      source: 'users'
      scope: element
      children: [
        type: 'element'
        tag: 'li'
        source: 'user'
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
    
    HandlerFactory.create options, context
    
    @assertEqual 2, element.childNodes.length
    context.get('users').remove 'John'
    @assertEqual 1, element.childNodes.length
  
  'test for node with deferred reset': ->
    options =
      type: 'for'
      source: 'users'
      scope: @parent
      children: [
        type: 'element'
        tag: 'span'
        source: 'user'
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
  
    HandlerFactory.create options, context
    
    @assertEqual 2, @parent.childNodes.length
    context.set users: ['Oliver']
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'Oliver', @parent.childNodes[0].innerHTML
  
  'test element node with single static style': ->
    options =
      type: 'element'
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
    
    HandlerFactory.create options
    @assertEqual 'red', @parent.childNodes[0].style.color
  
  'test element node with single dynamic style': ->
    options =
      type: 'element'
      tag: 'div'
      scope: @parent
      children: [
        type: 'text'
        value: 'test'
      ]
      styles:
        color:
          type: 'text'
          value: 'color'
          isDynamic: true
    
    context = new WingmanObject
    context.set color: 'red'
    
    HandlerFactory.create options, context
    
    @assertEqual 'red', @parent.childNodes[0].style.color
  
  'test deferred reset with element node with single dynamic style': ->
    options =
      type: 'element'
      tag: 'div'
      scope: @parent
      children: [
        type: 'text'
        value: 'test'
      ]
      styles:
        color:
          type: 'text'
          value: 'color'
          isDynamic: true
    
    context = new WingmanObject
    context.set color: 'red'
    HandlerFactory.create options, context
    context.set color: 'blue'
    @assertEqual 'blue', @parent.childNodes[0].style.color
  
  'test element node with two static styles': ->
    options =
      type: 'element'
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
    
    HandlerFactory.create options
    element = @parent.childNodes[0]
    @assertEqual 'red', element.style.color
    @assertEqual '15px', element.style.fontSize
  
  'test element node with two static styles': ->
    options =
      type: 'element'
      tag: 'div'
      scope: @parent
      children: [
        type: 'text'
        value: 'test'
      ]
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
    HandlerFactory.create options, context
    style = @parent.childNodes[0].style
    @assertEqual 'red', style.color
    @assertEqual '15px', style.fontSize
  
    context.set myColor: 'blue', myFontSize: '13px'
    @assertEqual 'blue', style.color
    @assertEqual '13px', style.fontSize
  
  'test element node with two dynamic styles': ->
    options =
      type: 'element'
      tag: 'div'
      scope: @parent
      children: [
        type: 'text'
        value: 'test'
      ]
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
    HandlerFactory.create options, context
    
    element = @parent.childNodes[0]
    @assertEqual 'red', element.style.color
    @assertEqual '15px', element.style.fontSize
    
    context.set myColor: 'blue', myFontSize: '13px'
    @assertEqual 'blue', element.style.color
    @assertEqual '13px', element.style.fontSize
  
  'test element node with single static class': ->
    options =
      type: 'element'
      tag: 'div'
      scope: @parent
      classes: [
        type: 'text'
        value: 'user'
      ]
    
    HandlerFactory.create options
    @assertEqual @parent.childNodes[0].className, 'user'
  
  'test element node with two static classes': ->
    options =
      type: 'element'
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
    
    HandlerFactory.create options
    element = @parent.childNodes[0]
    @assertDOMElementHasClass element, 'user'
    @assertDOMElementHasClass element, 'premium'
  
  'test element node with single dynamic class': ->
    options =
      type: 'element'
      tag: 'div'
      scope: @parent
      classes: [
        type: 'text'
        value: 'myAwesomeClass'
        isDynamic: true
      ]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    HandlerFactory.create options, context
    @assertDOMElementHasClass @parent.childNodes[0], 'user'
  
  'test deferred reset with element node with single dynamic class': ->
    options =
      type: 'element'
      tag: 'div'
      scope: @parent
      classes: [
        type: 'text'
        value: 'myAwesomeClass'
        isDynamic: true
      ]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    HandlerFactory.create options, context
    element = @parent.childNodes[0]
    @assertEqual element.className, 'user'
    context.set myAwesomeClass: 'something_else'
    @assertEqual element.className, 'something_else'
  
  'test deferred reset to falsy value with element node with single dynamic class': ->
    options =
      type: 'element'
      tag: 'div'
      scope: @parent
      classes: [
        type: 'text'
        value: 'myAwesomeClass'
        isDynamic: true
      ]
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    HandlerFactory.create options, context
    element = @parent.childNodes[0]
    @assertEqual element.className, 'user'
    context.set myAwesomeClass: null
    @assertEqual element.className, ''
  
  'test element node with two dynamic classes that evaluates to the same value': ->
    elementNode =
      type: 'element'
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
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user', mySuperbClass: 'user'
    
    HandlerFactory.create elementNode, context
    @assertEqual @parent.childNodes[0].className, 'user'
  
  'test deferred reset of dynamic class that evaluates to the same value as another dynamic class in node element': ->
    elementNode =
      type: 'element'
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
    
    context = new WingmanObject
    context.set myAwesomeClass: 'user', mySuperbClass: 'user'
    
    HandlerFactory.create elementNode, context
    context.set myAwesomeClass: 'premium'
    
    element = @parent.childNodes[0]
    @assertDOMElementHasClass element, 'user'
    @assertDOMElementHasClass element, 'premium'
  
  'test child view': ->
    elementNode =
      type: 'childView'
      name: 'user'
      scope: @parent
    
    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: -> '<div>I am the user view</div>'
    
    mainView = new MainView
    HandlerFactory.create elementNode, mainView
    @assertEqual '<div>I am the user view</div>', @parent.childNodes[0].innerHTML
  
  'test conditional': ->
    options =
      type: 'conditional'
      source: 'something'
      scope: @parent
      trueChildren: [
        {
          type: 'element'
          tag: 'span'
          children: [
            type: 'text'
            value: 'user'
          ]
        },
        {
          type: 'element'
          tag: 'span'
          children: [
            type: 'text'
            value: 'user2'
          ]
        }
      ]
    
    context = new WingmanObject
    context.set something: true
    HandlerFactory.create options, context
    
    childNodes = @parent.childNodes
    @assertEqual 2, childNodes.length
    @assertEqual 'user', childNodes[0].innerHTML
    @assertEqual 'user2', childNodes[1].innerHTML
    context.set something: false
    @assertEqual 0, childNodes.length
  
  'test if else conditonal': ->
    options =
      type: 'conditional'
      source: 'early'
      scope: @parent
      trueChildren: [
        {
          type: 'element'
          tag: 'span'
          children: [
            type: 'text'
            value: 'good morning'
          ]
        }
        {
          type: 'element'
          tag: 'span'
          children: [
            type: 'text'
            value: 'good morning again'
          ]
        }
      ]
      falseChildren: [
        type: 'element'
        tag: 'span'
        children: [
          type: 'text'
          value: 'good evening'
        ]
      ]
    
    context = new WingmanObject
    context.set early: true
    HandlerFactory.create options, context
    
    childNodes = @parent.childNodes
    @assertEqual 2, childNodes.length
    @assertEqual 'good morning', childNodes[0].innerHTML
    @assertEqual 'good morning again', childNodes[1].innerHTML
    context.set early: false
    @assertEqual 1, childNodes.length
    @assertEqual 'good evening', childNodes[0].innerHTML
