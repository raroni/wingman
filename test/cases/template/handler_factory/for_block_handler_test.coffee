document = require('jsdom').jsdom()
Janitor = require 'janitor'
WingmanObject = require '../../../../lib/wingman/shared/object'
ForBlockHandler = require '../../../../lib/wingman/template/handler_factory/for_block_handler'
Wingman = require '../../../../.'

module.exports = class ForBlockHandlerTest extends Janitor.TestCase
  setup: ->
    Wingman.document = document
    @parent = Wingman.document.createElement 'div'
  
  teardown: ->
    delete Wingman.document
  
  'test simple for block': ->
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
    
    new ForBlockHandler options, context
    
    childElements = @parent.childNodes
    @assertEqual 2, childElements.length
    @assertEqual 'Rasmus', childElements[0].innerHTML
    @assertEqual 'John', childElements[1].innerHTML
  
  'test several children': ->
    options =
      type: 'for'
      source: 'users'
      scope: @parent
      children: [
        {
          type: 'element'
          tag: 'span'
          children: [
            type: 'text'
            value: 'Username:'
          ]
        }
        {
          type: 'element'
          tag: 'span'
          source: 'user'
        }
      ]
    
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
  
    new ForBlockHandler options, context
    
    childElements = @parent.childNodes
    @assertEqual 4, childElements.length
    @assertEqual 'Username:', childElements[0].innerHTML
    @assertEqual 'Rasmus', childElements[1].innerHTML
    @assertEqual 'Username:', childElements[2].innerHTML
    @assertEqual 'John', childElements[3].innerHTML
  
  'test for node with nested source path': ->
    options =
      type: 'for'
      source: 'user.notifications'
      scope: @parent
      children: [
        type: 'element'
        tag: 'span'
        source: 'notification'
      ]
  
    context = new WingmanObject
    user = new WingmanObject
    user.set notifications: ['Hello', 'Hi']
    context.set { user }
  
    new ForBlockHandler options, context
  
    childElements = @parent.childNodes
    @assertEqual 2, childElements.length
    @assertEqual 'Hello', childElements[0].innerHTML
    @assertEqual 'Hi', childElements[1].innerHTML
  
  'test for node with deferred push': ->
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
    
    new ForBlockHandler options, context
    
    childElements = @parent.childNodes
    @assertEqual 2, childElements.length
    context.get('users').push 'Joe'
    @assertEqual 3, childElements.length
    @assertEqual 'Joe', childElements[2].innerHTML
  
  'test for node with deferred remove': ->
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
  
    new ForBlockHandler options, context, 'users'
    
    childElements = @parent.childNodes
    @assertEqual 2, childElements.length
    context.get('users').remove 'John'
    @assertEqual 1, childElements.length
  
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
  
    new ForBlockHandler options, context
    
    @assertEqual 2, @parent.childNodes.length
    context.set users: ['Oliver']
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'Oliver', @parent.childNodes[0].innerHTML
  
  'test for node with no initial source': ->
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
    
    new ForBlockHandler options, context, 'users'
    childElements = @parent.childNodes
    
    @assertEqual 0, childElements.length
    context.set users: ['Rasmus', 'Mario']
    @assertEqual 2, childElements.length
    @assertEqual 'Rasmus', childElements[0].innerHTML
    @assertEqual 'Mario', childElements[1].innerHTML
  
  'test child view': ->
    options =
      type: 'for'
      source: 'users'
      scope: @parent
      children: [
        type: 'childView'
        name: 'user'
      ]
    
    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: -> '<div>{user}</div>'
    
    mainView = new MainView
    mainView.set users: ['Luigi', 'Yoshi']
    new ForBlockHandler options, mainView
    @assertEqual '<div>Luigi</div>', @parent.childNodes[0].innerHTML
    @assertEqual '<div>Yoshi</div>', @parent.childNodes[1].innerHTML
