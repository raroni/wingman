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
      source: 'users'
      scope: @parent
      children: [
        type: 'element'
        tag: 'span'
        source: 'user'
      ]
    
    context = new WingmanObject
    
    new ForBlockHandler options, context
    childElements = @parent.childNodes
    
    @assertEqual 0, childElements.length
    context.set users: ['Rasmus', 'Mario']
    @assertEqual 2, childElements.length
    @assertEqual 'Rasmus', childElements[0].innerHTML
    @assertEqual 'Mario', childElements[1].innerHTML
  
  'test child view': ->
    options =
      source: 'users'
      scope: @parent
      children: [
        type: 'childView'
        name: 'sub'
      ]

    class MainView extends Wingman.View
    class MainView.SubView extends Wingman.View
      templateSource: 'Hello'
    
    mainView = new MainView
    mainView.set users: ['Luigi', 'Yoshi']
    new ForBlockHandler options, mainView
    @assertEqual 'Hello', @parent.childNodes[0].innerHTML
    @assertEqual 'Hello', @parent.childNodes[1].innerHTML
  
  'test child view where name equals singular of source': ->
    options =
      source: 'users'
      scope: @parent
      children: [
        type: 'childView'
        name: 'user'
      ]
    
    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: '{user}'
    
    mainView = new MainView
    mainView.set users: ['Luigi', 'Yoshi']
    new ForBlockHandler options, mainView
    @assertEqual 'Luigi', @parent.childNodes[0].innerHTML
    @assertEqual 'Yoshi', @parent.childNodes[1].innerHTML
  
  'test child view with path name pointing to property on parent view': ->
    options =
      source: 'users'
      scope: @parent
      children: [
        type: 'childView'
        path: 'mySubView'
        properties: ['user']
      ]
    
    class MainView extends Wingman.View
      mySubView: -> 'user'
    
    class MainView.UserView extends Wingman.View
      templateSource: '{user}'
    
    mainView = new MainView
    mainView.set users: ['Luigi', 'Yoshi']
    new ForBlockHandler options, mainView
    @assertEqual 'Luigi', @parent.childNodes[0].innerHTML
    @assertEqual 'Yoshi', @parent.childNodes[1].innerHTML

  'test child view with path name pointing to property on iterated elements': ->
    options =
      source: 'users'
      scope: @parent
      children: [
        type: 'childView'
        path: 'user.myMethod'
        properties: ['user']
      ]
    
    class MainView extends Wingman.View
      mySubView: -> 'user'
    
    class MainView.SecretView extends Wingman.View
      templateSource: '{user.name}'
    
    class User extends Wingman.Model
      myMethod: -> 'secret'
    
    user1 = new User name: 'Thelma'
    user2 = new User name: 'Louise'
    users = [user1, user2]
    
    mainView = new MainView
    mainView.set { users }
    new ForBlockHandler options, mainView
    @assertEqual 'Thelma', @parent.childNodes[0].innerHTML
    @assertEqual 'Louise', @parent.childNodes[1].innerHTML
