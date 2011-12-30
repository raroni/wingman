document = require('jsdom').jsdom()
Janitor = require 'janitor'
Value = require '../../../lib/wingman/template/parser/value'
Element = require '../../../lib/wingman/template/node_interpreter/element'
Wingman = require '../../../.'

module.exports = class extends Janitor.TestCase
  setup: ->
    Wingman.Template.document = document
  
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
    ni = new Element node_data, scope
    @assert ni.dom_element
    @assert_equal 'DIV', ni.dom_element.tagName
  
  'test simple element node in dom scope': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')

    scope = document.createElement 'li'
    ni = new Element node_data, scope

    @assert ni.dom_element
    @assert_equal 'DIV', ni.dom_element.tagName
    @assert_equal 'LI', ni.dom_element.parentNode.tagName
  
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

    ni = new Element node_data, scope
    @assert ni.dom_element
    @assert_equal 'DIV', ni.dom_element.tagName
    @assert_equal 1, ni.dom_element.childNodes.length
    @assert_equal 'SPAN', ni.dom_element.childNodes[0].tagName
    @assert_equal 'test', ni.dom_element.childNodes[0].innerHTML

  'test element node with dynamic value': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')

    context = new Wingman.Object
    context.set name: 'Rasmus'
    ni = new Element node_data, [], context

    @assert_equal 'Rasmus', ni.dom_element.innerHTML
  
  'test element node with dynamic value and defered update': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{name}')

    context = new Wingman.Object
    context.set name: 'John'
    ni = new Element node_data, [], context
    @assert_equal 'John', ni.dom_element.innerHTML
    context.set name: 'Rasmus'

    @assert_equal 'Rasmus', ni.dom_element.innerHTML
  
  'test element node with dynamic nested value and defered update': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('{user.name}')

    user = new Wingman.Object
    user.set name: 'John'
    context = new Wingman.Object
    context.set {user}
    ni = new Element node_data, [], context
    @assert_equal 'John', ni.dom_element.innerHTML
    user.set name: 'Rasmus'

    @assert_equal 'Rasmus', ni.dom_element.innerHTML
  
  'test element node with single static style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
    
    ni = new Element node_data, []
    
    @assert_equal 'red', ni.dom_element.style.color
  
  'test element node with single dynamic style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new Wingman.Object
    context.set color: 'red'
    ni = new Element node_data, [], context
    
    @assert_equal 'red', ni.dom_element.style.color
  
  'test deferred reset with element node with single dynamic style': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('{color}')
    
    context = new Wingman.Object
    context.set color: 'red'
    ni = new Element node_data, [], context
    context.set color: 'blue'
    @assert_equal 'blue', ni.dom_element.style.color
  
  'test element node with several static styles': ->
    node_data = 
      type: 'element'
      tag: 'div'
      value: new Value('test')
      styles:
        color: new Value('red')
        'font-size': new Value('15px')
    
    ni = new Element node_data, []
    
    @assert_equal 'red', ni.dom_element.style.color
    @assert_equal '15px', ni.dom_element.style.fontSize
