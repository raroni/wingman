document = require('jsdom').jsdom()
Janitor = require 'janitor'
Value = require '../../../../lib/wingman-client/template/parser/value'
WingmanObject = require '../../../../lib/wingman-client/shared/object'
ForBlock = require '../../../../lib/wingman-client/template/node_interpreter/for_block'
Wingman = require '../../../../.'

module.exports = class ForBlockTest extends Janitor.TestCase
  setup: ->
    Wingman.document = document
    @parent = Wingman.document.createElement 'div'

  'test simple for block': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
  
    new ForBlock node_data, @parent, context
    
    child_elements = @parent.childNodes
    @assertEqual 2, child_elements.length
    @assertEqual 'Rasmus', child_elements[0].innerHTML
    @assertEqual 'John', child_elements[1].innerHTML
  
  'test several children': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        {
          type: 'element'
          tag: 'span'
          value: new Value('Username:')
        }
        {
          type: 'element'
          tag: 'span'
          value: new Value('{user}')
        }
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
  
    new ForBlock node_data, @parent, context
    
    child_elements = @parent.childNodes
    @assertEqual 4, child_elements.length
    @assertEqual 'Username:', child_elements[0].innerHTML
    @assertEqual 'Rasmus', child_elements[1].innerHTML
    @assertEqual 'Username:', child_elements[2].innerHTML
    @assertEqual 'John', child_elements[3].innerHTML
  
  'test for node with nested source path': ->
    node_data =
      type: 'for'
      source: 'user.notifications'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('{notification}')
      ]
  
    context = new WingmanObject
    user = new WingmanObject
    user.set notifications: ['Hello', 'Hi']
    context.set { user }
  
    new ForBlock node_data, @parent, context
  
    child_elements = @parent.childNodes
    @assertEqual 2, child_elements.length
    @assertEqual 'Hello', child_elements[0].innerHTML
    @assertEqual 'Hi', child_elements[1].innerHTML
  
  'test for node with deferred push': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
    
    new ForBlock node_data, @parent, context
    
    child_elements = @parent.childNodes
    @assertEqual 2, child_elements.length
    context.get('users').push 'Joe'
    @assertEqual 3, child_elements.length
    @assertEqual 'Joe', child_elements[2].innerHTML
  
  'test for node with deferred remove': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
  
    new ForBlock node_data, @parent, context, 'users'
    
    child_elements = @parent.childNodes
    @assertEqual 2, child_elements.length
    context.get('users').remove 'John'
    @assertEqual 1, child_elements.length
  
  'test for node with deferred reset': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
  
    new ForBlock node_data, @parent, context
    
    @assertEqual 2, @parent.childNodes.length
    context.set users: ['Oliver']
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'Oliver', @parent.childNodes[0].innerHTML
  
  'test for node with no initial source': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    
    new ForBlock node_data, @parent, context, 'users'
    child_elements = @parent.childNodes
    
    @assertEqual 0, child_elements.length
    context.set users: ['Rasmus', 'Mario']
    @assertEqual 2, child_elements.length
    @assertEqual 'Rasmus', child_elements[0].innerHTML
    @assertEqual 'Mario', child_elements[1].innerHTML
  
  'test child view': ->
    node_data =
      type: 'for'
      source: 'users'
      children: [
        type: 'child_view'
        name: 'user'
      ]
    
    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: -> '<div>{user}</div>'
    
    main_view = new MainView
    main_view.set users: ['Luigi', 'Yoshi']
    new ForBlock node_data, @parent, main_view
    @assertEqual '<div>Luigi</div>', @parent.childNodes[0].innerHTML
    @assertEqual '<div>Yoshi</div>', @parent.childNodes[1].innerHTML
