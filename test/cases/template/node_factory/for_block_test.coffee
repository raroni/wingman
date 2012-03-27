document = require('jsdom').jsdom()
Janitor = require 'janitor'
Value = require '../../../../lib/wingman/template/parser/value'
WingmanObject = require '../../../../lib/wingman/shared/object'
ForBlock = require '../../../../lib/wingman/template/node_factory/for_block'
Wingman = require '../../../../.'

module.exports = class ForBlockTest extends Janitor.TestCase
  setup: ->
    Wingman.document = document
    @parent = Wingman.document.createElement 'div'

  'test simple for block': ->
    nodeData =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
  
    new ForBlock nodeData, @parent, context
    
    childElements = @parent.childNodes
    @assertEqual 2, childElements.length
    @assertEqual 'Rasmus', childElements[0].innerHTML
    @assertEqual 'John', childElements[1].innerHTML
  
  'test several children': ->
    nodeData =
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
  
    new ForBlock nodeData, @parent, context
    
    childElements = @parent.childNodes
    @assertEqual 4, childElements.length
    @assertEqual 'Username:', childElements[0].innerHTML
    @assertEqual 'Rasmus', childElements[1].innerHTML
    @assertEqual 'Username:', childElements[2].innerHTML
    @assertEqual 'John', childElements[3].innerHTML
  
  'test for node with nested source path': ->
    nodeData =
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
  
    new ForBlock nodeData, @parent, context
  
    childElements = @parent.childNodes
    @assertEqual 2, childElements.length
    @assertEqual 'Hello', childElements[0].innerHTML
    @assertEqual 'Hi', childElements[1].innerHTML
  
  'test for node with deferred push': ->
    nodeData =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
    
    new ForBlock nodeData, @parent, context
    
    childElements = @parent.childNodes
    @assertEqual 2, childElements.length
    context.get('users').push 'Joe'
    @assertEqual 3, childElements.length
    @assertEqual 'Joe', childElements[2].innerHTML
  
  'test for node with deferred remove': ->
    nodeData =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
  
    new ForBlock nodeData, @parent, context, 'users'
    
    childElements = @parent.childNodes
    @assertEqual 2, childElements.length
    context.get('users').remove 'John'
    @assertEqual 1, childElements.length
  
  'test for node with deferred reset': ->
    nodeData =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
  
    new ForBlock nodeData, @parent, context
    
    @assertEqual 2, @parent.childNodes.length
    context.set users: ['Oliver']
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'Oliver', @parent.childNodes[0].innerHTML
  
  'test for node with no initial source': ->
    nodeData =
      type: 'for'
      source: 'users'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('{user}')
      ]
    
    context = new WingmanObject
    
    new ForBlock nodeData, @parent, context, 'users'
    childElements = @parent.childNodes
    
    @assertEqual 0, childElements.length
    context.set users: ['Rasmus', 'Mario']
    @assertEqual 2, childElements.length
    @assertEqual 'Rasmus', childElements[0].innerHTML
    @assertEqual 'Mario', childElements[1].innerHTML
  
  'test child view': ->
    nodeData =
      type: 'for'
      source: 'users'
      children: [
        type: 'childView'
        name: 'user'
      ]
    
    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: -> '<div>{user}</div>'
    
    mainView = new MainView
    mainView.set users: ['Luigi', 'Yoshi']
    new ForBlock nodeData, @parent, mainView
    @assertEqual '<div>Luigi</div>', @parent.childNodes[0].innerHTML
    @assertEqual '<div>Yoshi</div>', @parent.childNodes[1].innerHTML
