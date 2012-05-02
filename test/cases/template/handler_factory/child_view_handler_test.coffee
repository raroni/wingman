document = require('jsdom').jsdom()
Janitor = require 'janitor'
ChildViewHandler = require '../../../../lib/wingman/template/handler_factory/child_view_handler'
Wingman = require '../../../../.'

module.exports = class ChildViewHandlerTest extends Janitor.TestCase
  setup: ->
    Wingman.document = document
    @parent = Wingman.document.createElement 'div'
  
  teardown: ->
    delete Wingman.document
  
  'test simple child view': ->
    options =
      name: 'user'
      scope: @parent
    
    MainView = Wingman.View.extend()
    MainView.UserView = Wingman.View.extend
      templateSource: '<div>I am the user view</div>'
    
    mainView = MainView.create()
    ChildViewHandler.create { options, context: mainView }
    @assertEqual '<div>I am the user view</div>', @parent.childNodes[0].innerHTML
  
  'test passing value from context': ->
    options =
      name: 'user'
      scope: @parent
      properties: ['user', 'height']
    
    MainView = Wingman.View.extend()
    MainView.UserView = Wingman.View.extend
      templateSource: null
    
    mainView = MainView.create()
    mainView.set
      user:
        name: 'Rasmus'
      width: 100
      height: 200
    
    handler = ChildViewHandler.create { options, context: mainView }
    view = handler.view
    @assertEqual 'Rasmus', view.user.name
    @assertEqual 200, view.height
    @assert !view.width
  
  'test using passed value in automatic styles': ->
    options =
      name: 'user'
      scope: @parent
      passPropertyNames: ['user']
    
    MainView = Wingman.View.extend()
    MainView.UserView = Wingman.View.extend
      templateSource: null
      
      getLeft: ->
        "#{@user.level*10}px"
    
    mainView = MainView.create()
    mainView.user = { level: 3 }
    ChildViewHandler.create { options, context: mainView }
    @assertEqual '30px', @parent.childNodes[0].style.left
  
  'test remove': ->
    options =
      name: 'user'
      scope: @parent
    
    MainView = Wingman.View.extend()
    MainView.UserView = Wingman.View.extend
      templateSource: '<div>I am the user view</div>'
    
    mainView = MainView.create()
    handler = ChildViewHandler.create { options, context: mainView }
    
    @assertEqual 1, @parent.childNodes.length
    
    handler.remove()
    @assertEqual 0, @parent.childNodes.length
  
  'test dynamic name': ->
    options =
      path: 'myViewName'
      scope: @parent
    
    MainView = Wingman.View.extend
      getMyViewName: -> 'user'
      
    MainView.UserView = Wingman.View.extend
      templateSource: null
    
    mainView = MainView.create()
    handler = ChildViewHandler.create { options, context: mainView }
    @assert handler.view instanceof MainView.UserView
