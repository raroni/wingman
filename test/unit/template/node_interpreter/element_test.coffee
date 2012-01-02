document = require('jsdom').jsdom()
Janitor = require 'janitor'
Value = require '../../../../lib/wingman/template/parser/value'
Element = require '../../../../lib/wingman/template/node_interpreter/element'
Wingman = require '../../../../.'
CustomAssertions = require '../../../custom_assertions'

module.exports = class extends Janitor.TestCase
  setup: ->
    Wingman.Template.document = document
  
  assertDOMElementHasClass: CustomAssertions.assertDOMElementHasClass
  refuteDOMElementHasClass: CustomAssertions.refuteDOMElementHasClass
  
  'test css property name convertion from dom to css notation': ->
    @assert_equal 'fontSize', Element.convertCssPropertyFromDomToCssNotation 'font-size'
    @assert_equal 'marginTop', Element.convertCssPropertyFromDomToCssNotation 'margin-top'
    @assert_equal 'borderTopColor', Element.convertCssPropertyFromDomToCssNotation 'border-top-color'

  'test simple element': ->
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('test')

    scope = []
    element = new Element element_node, scope
    @assert element.dom_element
    @assert_equal 'DIV', element.dom_element.tagName
  
  'test simple element in dom scope': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('test')

    scope = document.createElement 'li'
    element = new Element element_node, scope

    @assert element.dom_element
    @assert_equal 'DIV', element.dom_element.tagName
    @assert_equal 'LI', element.dom_element.parentNode.tagName
  
  'test nested elements': ->
    element_node = 
      type: 'element'
      tag: 'div'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('test')
      ]

    scope = []

    element = new Element element_node, scope
    @assert element.dom_element
    @assert_equal 'DIV', element.dom_element.tagName
    @assert_equal 1, element.dom_element.childNodes.length
    @assert_equal 'SPAN', element.dom_element.childNodes[0].tagName
    @assert_equal 'test', element.dom_element.childNodes[0].innerHTML

  'test element with dynamic value': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')

    context = new Wingman.Object
    context.set name: 'Rasmus'
    element = new Element element_node, [], context

    @assert_equal 'Rasmus', element.dom_element.innerHTML
  
  'test element with dynamic value and defered update': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')

    context = new Wingman.Object
    context.set name: 'John'
    element = new Element element_node, [], context
    @assert_equal 'John', element.dom_element.innerHTML
    context.set name: 'Rasmus'

    @assert_equal 'Rasmus', element.dom_element.innerHTML
  
  'test element with dynamic nested value and defered update': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('{user.name}')

    user = new Wingman.Object
    user.set name: 'John'
    context = new Wingman.Object
    context.set {user}
    element = new Element element_node, [], context
    @assert_equal 'John', element.dom_element.innerHTML
    user.set name: 'Rasmus'

    @assert_equal 'Rasmus', element.dom_element.innerHTML
  
  'test element with single static style': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
    
    element = new Element element_node, []
    
    @assert_equal 'red', element.dom_element.style.color
  
  'test element with single dynamic style': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new Wingman.Object
    context.set color: 'red'
    element = new Element element_node, [], context
    
    @assert_equal 'red', element.dom_element.style.color
  
  'test deferred reset with element with single dynamic style': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new Wingman.Object
    context.set color: 'red'
    element = new Element element_node, [], context
    context.set color: 'blue'
    @assert_equal 'blue', element.dom_element.style.color
  
  'test element with two static styles': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
        'font-size': new Value('15px')
    
    element = new Element element_node, []
    
    @assert_equal 'red', element.dom_element.style.color
    @assert_equal '15px', element.dom_element.style.fontSize

  'test element with two dynamic styles': ->
    element_node = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{myColor}')
        'font-size': new Value('{myFontSize}')
    
    context = new Wingman.Object
    context.set myColor: 'red', myFontSize: '15px'
    element = new Element element_node, [], context

    @assert_equal 'red', element.dom_element.style.color
    @assert_equal '15px', element.dom_element.style.fontSize

    context.set myColor: 'blue', myFontSize: '13px'
    @assert_equal 'blue', element.dom_element.style.color
    @assert_equal '13px', element.dom_element.style.fontSize
  
  'test element with single static class': ->
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('user')]
    
    element = new Element element_node, []
    @assert_equal element.dom_element.className, 'user'
  
  'test element with two static classes': ->
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('user'), new Value('premium')]
    
    element = new Element element_node, []
    @assertDOMElementHasClass element.dom_element, 'user'
    @assertDOMElementHasClass element.dom_element, 'premium'
  
  'test element with single dynamic class': ->
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new Wingman.Object
    context.set myAwesomeClass: 'user'

    element = new Element element_node, [], context
    @assertDOMElementHasClass element.dom_element, 'user'
  
  'test deferred reset with element with single dynamic class': ->
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new Wingman.Object
    context.set myAwesomeClass: 'user'

    element = new Element element_node, [], context
    @assert_equal element.dom_element.className, 'user'
    context.set myAwesomeClass: 'something_else'
    @assert_equal element.dom_element.className, 'something_else'

  'test deferred reset to falsy value with element with single dynamic class': ->
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new Wingman.Object
    context.set myAwesomeClass: 'user'

    element = new Element element_node, [], context
    @assert_equal element.dom_element.className, 'user'
    context.set myAwesomeClass: null
    @assert_equal element.dom_element.className, ''
  
  'test element with two dynamic classes that evaluates to the same value': ->
    element_node =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [
        new Value('{myAwesomeClass}'),
        new Value('{mySuperbClass}')
      ]
    
    context = new Wingman.Object
    context.set myAwesomeClass: 'user', mySuperbClass: 'user'

    element = new Element element_node, [], context
    @assert_equal element.dom_element.className, 'user'
