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

  'test simple element node': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('test')

    scope = []
    element = new Element node_data, scope
    @assert element.dom_element
    @assert_equal 'DIV', element.dom_element.tagName
  
  'test simple element node in dom scope': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')

    scope = document.createElement 'li'
    element = new Element node_data, scope

    @assert element.dom_element
    @assert_equal 'DIV', element.dom_element.tagName
    @assert_equal 'LI', element.dom_element.parentNode.tagName
  
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

    element = new Element node_data, scope
    @assert element.dom_element
    @assert_equal 'DIV', element.dom_element.tagName
    @assert_equal 1, element.dom_element.childNodes.length
    @assert_equal 'SPAN', element.dom_element.childNodes[0].tagName
    @assert_equal 'test', element.dom_element.childNodes[0].innerHTML

  'test element node with dynamic value': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')

    context = new Wingman.Object
    context.set name: 'Rasmus'
    element = new Element node_data, [], context

    @assert_equal 'Rasmus', element.dom_element.innerHTML
  
  'test element node with dynamic value and defered update': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')

    context = new Wingman.Object
    context.set name: 'John'
    element = new Element node_data, [], context
    @assert_equal 'John', element.dom_element.innerHTML
    context.set name: 'Rasmus'

    @assert_equal 'Rasmus', element.dom_element.innerHTML
  
  'test element node with dynamic nested value and defered update': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{user.name}')

    user = new Wingman.Object
    user.set name: 'John'
    context = new Wingman.Object
    context.set {user}
    element = new Element node_data, [], context
    @assert_equal 'John', element.dom_element.innerHTML
    user.set name: 'Rasmus'

    @assert_equal 'Rasmus', element.dom_element.innerHTML
  
  'test element node with single static style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
    
    element = new Element node_data, []
    
    @assert_equal 'red', element.dom_element.style.color
  
  'test element node with single dynamic style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new Wingman.Object
    context.set color: 'red'
    element = new Element node_data, [], context
    
    @assert_equal 'red', element.dom_element.style.color
  
  'test deferred reset with element node with single dynamic style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new Wingman.Object
    context.set color: 'red'
    element = new Element node_data, [], context
    context.set color: 'blue'
    @assert_equal 'blue', element.dom_element.style.color
  
  'test element node with two static styles': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
        'font-size': new Value('15px')
    
    element = new Element node_data, []
    
    @assert_equal 'red', element.dom_element.style.color
    @assert_equal '15px', element.dom_element.style.fontSize

  'test element node with two dynamic styles': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{myColor}')
        'font-size': new Value('{myFontSize}')
    
    context = new Wingman.Object
    context.set myColor: 'red', myFontSize: '15px'
    element = new Element node_data, [], context

    @assert_equal 'red', element.dom_element.style.color
    @assert_equal '15px', element.dom_element.style.fontSize

    context.set myColor: 'blue', myFontSize: '13px'
    @assert_equal 'blue', element.dom_element.style.color
    @assert_equal '13px', element.dom_element.style.fontSize
  
  'test element node with single static class': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('user')]
    
    element = new Element node_data, []
    @assert_equal element.dom_element.className, 'user'
  
  'test element node with two static classes': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('user'), new Value('premium')]
    
    element = new Element node_data, []
    @assertDOMElementHasClass element.dom_element, 'user'
    @assertDOMElementHasClass element.dom_element, 'premium'
  
  'test element node with single dynamic class': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new Wingman.Object
    context.set myAwesomeClass: 'user'

    element = new Element node_data, [], context
    @assertDOMElementHasClass element.dom_element, 'user'
  
  'test deferred reset with element node with single dynamic class': ->
    node_data =
      type: 'element'
      tag: 'div'
      value: new Value('Something')
      classes: [new Value('{myAwesomeClass}')]
    
    context = new Wingman.Object
    context.set myAwesomeClass: 'user'

    element = new Element node_data, [], context
    @assert_equal element.dom_element.className, 'user'
    context.set myAwesomeClass: 'something_else'
    @assert_equal element.dom_element.className, 'something_else'
