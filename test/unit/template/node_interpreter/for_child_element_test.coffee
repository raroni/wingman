document = require('jsdom').jsdom()
Janitor = require 'janitor'
Value = require '../../../../lib/wingman/template/parser/value'
ForChildElement = require '../../../../lib/wingman/template/node_interpreter/for_child_element'
Wingman = require '../../../../.'

module.exports = class extends Janitor.TestCase
  setup: ->
    Wingman.Template.document = document

  'test for node': ->
    node_data =
      type: 'element'
      tag: 'li'
      value: new Value('{user}')
    
    context = new Wingman.Object
    context.set users: ['Rasmus', 'John']

    parent_element = document.createElement 'ol'
    new ForChildElement node_data, parent_element, context, 'users'
    
    child_elements = parent_element.childNodes
    @assert_equal 2, child_elements.length
    @assert_equal 'Rasmus', child_elements[0].innerHTML
    @assert_equal 'John', child_elements[1].innerHTML
  
  'test for node with deferred push': ->
      node_data =
        type: 'element'
        tag: 'li'
        value: new Value('{user}')
      
      context = new Wingman.Object
      context.set users: ['Rasmus', 'John']
  
      parent_element = document.createElement 'ol'
      new ForChildElement node_data, parent_element, context, 'users'
      
      child_elements = parent_element.childNodes
      @assert_equal 2, child_elements.length
      context.get('users').push 'Joe'
      @assert_equal 3, child_elements.length
      @assert_equal 'Joe', child_elements[2].innerHTML
  
    'test for node with deferred remove': ->
      node_data =
        type: 'element'
        tag: 'li'
        value: new Value('{user}')
      
      context = new Wingman.Object
      context.set users: ['Rasmus', 'John']
  
      parent_element = document.createElement 'ol'
      new ForChildElement node_data, parent_element, context, 'users'
      
      child_elements = parent_element.childNodes
      @assert_equal 2, child_elements.length
      context.get('users').remove 'John'
      @assert_equal 1, child_elements.length
  
    'test for node with deferred reset': ->
      node_data =
        type: 'element'
        tag: 'li'
        value: new Value('{user}')
      
      context = new Wingman.Object
      context.set users: ['Rasmus', 'John']
  
      element = document.createElement 'ol'
      new ForChildElement node_data, element, context, 'users'
      
      @assert_equal 2, element.childNodes.length
      context.set users: ['Oliver']
      @assert_equal 1, element.childNodes.length
      @assert_equal 'Oliver', element.childNodes[0].innerHTML
