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
    
    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: -> '<div>I am the user view</div>'
    
    mainView = new MainView
    new ChildViewHandler options, mainView
    @assertEqual '<div>I am the user view</div>', @parent.childNodes[0].innerHTML
  
  'test passing value from context': ->
    options =
      name: 'user'
      scope: @parent
    
    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: -> null
      
      left: ->
        "#{@get('user.level')*10}px"
    
    mainView = new MainView
    user = { name: 'Rasmus' }
    mainView.set { user }
    handler = new ChildViewHandler options, mainView
    view = handler.view
    @assertEqual 'Rasmus', view.get('user.name')
  
  'test using passed value in automatic styles': ->
    options =
      name: 'user'
      scope: @parent
    
    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: -> null
      
      left: ->
        "#{@get('user.level')*10}px"
    
    mainView = new MainView
    mainView.set user: { level: 3 }
    new ChildViewHandler options, mainView
    @assertEqual '30px', @parent.childNodes[0].style.left
  
  'test remove': ->
    options =
      name: 'user'
      scope: @parent
    
    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: -> '<div>I am the user view</div>'
    
    mainView = new MainView
    handler = new ChildViewHandler options, mainView
    
    @assertEqual 1, @parent.childNodes.length
    
    handler.remove()
    @assertEqual 0, @parent.childNodes.length
