document = require('jsdom').jsdom()
Janitor = require 'janitor'
Value = require '../../../../lib/wingman/template/parser/value'
WingmanObject = require '../../../../lib/wingman/shared/object'
ForChildElement = require '../../../../lib/wingman/template/node_interpreter/for_child_element'
Wingman = require '../../../../.'


module.exports = class extends Janitor.TestCase
  setup: ->
    Wingman.document = document

  'test for node': ->
    node_data =
      type: 'element'
      tag: 'li'
      value: new Value('{user}')
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']

    parent_element = document.createElement 'ol'
    new ForChildElement node_data, parent_element, context, 'users'
    
    child_elements = parent_element.childNodes
    @assertEqual 2, child_elements.length
    @assertEqual 'Rasmus', child_elements[0].innerHTML
    @assertEqual 'John', child_elements[1].innerHTML
  
  'test for node with deferred push': ->
    node_data =
      type: 'element'
      tag: 'li'
      value: new Value('{user}')
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']

    parent_element = document.createElement 'ol'
    new ForChildElement node_data, parent_element, context, 'users'
    
    child_elements = parent_element.childNodes
    @assertEqual 2, child_elements.length
    context.get('users').push 'Joe'
    @assertEqual 3, child_elements.length
    @assertEqual 'Joe', child_elements[2].innerHTML
  
  'test for node with deferred remove': ->
    node_data =
      type: 'element'
      tag: 'li'
      value: new Value('{user}')
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']

    parent_element = document.createElement 'ol'
    new ForChildElement node_data, parent_element, context, 'users'
    
    child_elements = parent_element.childNodes
    @assertEqual 2, child_elements.length
    context.get('users').remove 'John'
    @assertEqual 1, child_elements.length

  'test for node with deferred reset': ->
    node_data =
      type: 'element'
      tag: 'li'
      value: new Value('{user}')
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']

    element = document.createElement 'ol'
    new ForChildElement node_data, element, context, 'users'
    
    @assertEqual 2, element.childNodes.length
    context.set users: ['Oliver']
    @assertEqual 1, element.childNodes.length
    @assertEqual 'Oliver', element.childNodes[0].innerHTML

  'test for node with no initial source': ->
    node_data =
      type: 'element'
      tag: 'li'
      value: new Value('{user}')
    
    context = new WingmanObject
    
    parent_element = document.createElement 'ol'
    new ForChildElement node_data, parent_element, context, 'users'
    child_elements = parent_element.childNodes

    @assertEqual 0, child_elements.length
    context.set users: ['Rasmus', 'John']
    @assertEqual 2, child_elements.length
    @assertEqual 'Rasmus', child_elements[0].innerHTML
    @assertEqual 'John', child_elements[1].innerHTML
