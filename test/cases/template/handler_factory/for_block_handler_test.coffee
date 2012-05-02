document = require('jsdom').jsdom()
Janitor = require 'janitor'
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
    
    context = Wingman.Object.create users: ['Rasmus', 'John']
    
    ForBlockHandler.create { options, context }
    
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
    
    context = Wingman.Object.create users: ['Rasmus', 'John']
  
    ForBlockHandler.create { options, context }
    
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
    
    context = Wingman.Object.create()
    user = Wingman.Object.create notifications: ['Hello', 'Hi']
    context.user = user
    
    ForBlockHandler.create { options, context }
    
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
    
    context = Wingman.Object.create users: ['Rasmus', 'John']
    ForBlockHandler.create { options, context }
    
    childElements = @parent.childNodes
    @assertEqual 2, childElements.length
    context.users.push 'Joe'
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
    
    context = Wingman.Object.create users: ['Rasmus', 'John']
    ForBlockHandler.create { options, context }
    
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
    
    context = Wingman.Object.create users: ['Rasmus', 'John']
  
    ForBlockHandler.create { options, context }
    
    @assertEqual 2, @parent.childNodes.length
    context.users = ['Oliver']
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
    
    context = Wingman.Object.create users: null
    ForBlockHandler.create { options, context }
    
    childElements = @parent.childNodes
    @assertEqual 0, childElements.length
    context.users = ['Rasmus', 'Mario']
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
  
    MainView = Wingman.View.extend
      users: null
      
    MainView.SubView = Wingman.View.extend
      templateSource: 'Hello'
    
    mainView = MainView.create()
    mainView.users = ['Luigi', 'Yoshi']
    ForBlockHandler.create { options, context: mainView }
    @assertEqual 'Hello', @parent.childNodes[0].innerHTML
    @assertEqual 'Hello', @parent.childNodes[1].innerHTML
  
  'test child views descendantCreated event': ->
    options =
      source: 'users'
      scope: @parent
      children: [
        type: 'childView'
        name: 'sub'
      ]
    
    MainView = Wingman.View.extend
      users: null
    
    MainView.SubView = Wingman.View.extend
      templateSource: 'Hello'
    
    mainView = MainView.create()
    mainView.users = ['Luigi', 'Yoshi']
    callbackFired = false
    mainView.bind 'descendantCreated', -> callbackFired = true
    ForBlockHandler.create { options, context: mainView }
    @assert callbackFired
  
  'test child view where name equals singular of source': ->
    options =
      source: 'users'
      scope: @parent
      children: [
        type: 'childView'
        name: 'user'
      ]
    
    MainView = Wingman.View.extend
      users: null
    
    MainView.UserView = Wingman.View.extend
      templateSource: '{user}'
    
    mainView = MainView.create()
    mainView.users = ['Luigi', 'Yoshi']
    ForBlockHandler.create { options, context: mainView }
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
    
    MainView = Wingman.View.extend
      getMySubView: -> 'user'
      users: null
    
    MainView.UserView = Wingman.View.extend
      templateSource: '{user}'
    
    mainView = MainView.create()
    mainView.users = ['Luigi', 'Yoshi']
    ForBlockHandler.create { options, context: mainView }
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
    
    MainView = Wingman.View.extend
      mySubView: -> 'user'
      users: null
    
    MainView.SecretView = Wingman.View.extend
      templateSource: '{user.name}'
    
    User = Wingman.Model.extend
      getMyMethod: -> 'secret'
    
    user1 = User.create name: 'Thelma'
    user2 = User.create name: 'Louise'
    users = [user1, user2]
    
    mainView = MainView.create()
    mainView.users = users
    ForBlockHandler.create { options, context: mainView }
    @assertEqual 'Thelma', @parent.childNodes[0].innerHTML
    @assertEqual 'Louise', @parent.childNodes[1].innerHTML
