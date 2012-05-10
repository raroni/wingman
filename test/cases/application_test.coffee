Janitor = require 'janitor'
Wingman = require '../../.'
jsdom = require 'jsdom'
JSDomWindowPopStateDecorator = require '../jsdom_window_pop_state_decorator'
Wingman.localStorage = require 'localStorage'

Wingman.View.templateSources = {
  'user': '<div>stubbing the source</div>'
  'main': '<div>stubbing the source</div>'
}

class ViewWithTemplateSource extends Wingman.View
  templateSource: '<div>test</div>'

class ControllerWithView extends Wingman.Controller
  initialize: (options = {}) ->
    options.view = new ViewWithTemplateSource parent: { el: Wingman.document.createElement('div') }
    super options

module.exports = class ApplicationTest extends Janitor.TestCase
  setup: ->
    Wingman.document = jsdom.jsdom()
    Wingman.window = JSDomWindowPopStateDecorator.create(Wingman.document.createWindow())
  
  teardown: ->
    delete Wingman.Application.instance
    Wingman.View.templateSources = {}
    delete Wingman.document
    delete Wingman.window
  
  'test most basic application': ->
    MyApp = Wingman.Application.extend()
    MyApp.RootView = Wingman.View.extend
      templateSource: '<div>Hi</div>'
    
    app = MyApp.create el: Wingman.document.createElement('div')
    @assertEqual '<div>Hi</div>', app.el.innerHTML
  
  'test simple child view': ->
    MyApp = Wingman.Application.extend()
    MyApp.RootController = Wingman.Controller.extend()
    MyApp.UserController = Wingman.Controller.extend()
    
    MyApp.RootView = Wingman.View.extend
      templateSource: "{view 'user'}"
    
    MyApp.UserView = Wingman.View.extend
      templateSource: '<div>stubbing the source</div>'
    
    rootEl = Wingman.document.createElement 'div'
    app = MyApp.create el: rootEl
    @assert rootEl.innerHTML.match('stubbing the source')
  
  'test access to state': ->
    MyApp = Wingman.Application.extend()
    MyApp.RootController = Wingman.Controller.extend()
    MyApp.RootView = Wingman.View.extend
      templateSource: "{view 'user'}"
    
    MyApp.UserController = Wingman.Controller.extend
      ready: ->
        @state.controllerGreeting = 'Controller says hello'
    
    MyApp.UserView = ViewWithTemplateSource.extend
      ready: ->
        @state.viewGreeting = 'View says hello'
    
    rootEl = Wingman.document.createElement 'div'
    app = MyApp.create el: rootEl
    
    @assertEqual 'View says hello', app.get('state.viewGreeting')
    @assertEqual 'Controller says hello', app.get('state.controllerGreeting')
  
  'test singleton instance': ->
    MyApp = Wingman.Application.extend()
    MyApp.RootController = Wingman.Controller.extend()
    MyApp.RootView = ViewWithTemplateSource.extend()
    
    @assert !Wingman.Application.instance
    MyApp.create el: Wingman.document.createElement 'div'
    @assert Wingman.Application.instance
  
  'test instantiation of two apps': ->
    MyApp = Wingman.Application.extend()
    MyApp.RootController = Wingman.Controller.extend()
    MyApp.RootView = ViewWithTemplateSource.extend()
    
    appOptions = { el: Wingman.document.createElement('div') }
    MyApp.create appOptions
    
    routine = -> MyApp.create appOptions
    check = (e) -> e.message == "You cannot instantiate two Wingman apps at the same time."
    
    @assertThrows routine, check
  
  'test reading config params on applications instance': ->
    MyApp = Wingman.Application.extend
      host: 'test-host.com'
    
    MyApp.RootController = Wingman.Controller.extend()
    MyApp.RootView = ViewWithTemplateSource.extend()
    
    MyApp.create el: Wingman.document.createElement('div')
    
    @assertEqual 'test-host.com', Wingman.Application.instance?.host
  
  'test application ready callback': ->
    callbackFired = false
    
    MyApp = Wingman.Application.extend
      ready: -> callbackFired = true
    
    MyApp.RootController = Wingman.Controller.extend()
    MyApp.RootView = ViewWithTemplateSource.extend()
    
    app = MyApp.create el: Wingman.document.createElement('div')
    @assert callbackFired
  
  'test root controller callback': ->
    callbackFired = false
    
    MyApp = Wingman.Application.extend()
    MyApp.RootView = ViewWithTemplateSource.extend()
    MyApp.RootController = Wingman.Controller.extend
      ready: ->
        callbackFired = true
    
    MyApp.create el: Wingman.document.createElement('div')
    @assert callbackFired
  
  'test navigate and shared path': ->
    MyApp = Wingman.Application.extend()
    MyApp.RootController = Wingman.Controller.extend()
    MyApp.RootView = ViewWithTemplateSource.extend()
    
    app = MyApp.create el: Wingman.document.createElement 'div'
    app.navigate 'user'
    @assertEqual 'user', app.get('path')
  
  'test navigation options': ->
    MyApp = Wingman.Application.extend()
    MyApp.RootController = Wingman.Controller.extend()
    MyApp.RootView = ViewWithTemplateSource.extend()
    
    app = MyApp.create el: Wingman.document.createElement 'div'
    app.navigate 'user', level: 2
    @assertEqual 'user', app.path
    @assertEqual 2, app.navigationOptions.level
  
  'test initial path': ->
    MyApp = Wingman.Application.extend()
    MyApp.RootController = Wingman.Controller.extend()
    MyApp.RootView = ViewWithTemplateSource.extend()
    
    Wingman.window.document.location.pathname = '/user'
    app = MyApp.create el: Wingman.document.createElement('div')
    @assertEqual 'user', app.path
  
  'test backing through history': ->
    MyApp = Wingman.Application.extend()
    MyApp.RootController = Wingman.Controller.extend()
    MyApp.RootView = ViewWithTemplateSource.extend()
  
    app = MyApp.create el: Wingman.document.createElement 'div'
    app.navigate 'user'
    app.navigate 'home'
    app.back()
    @assertEqual 'user', app.path
    @assertEqual '/user', Wingman.window.location.pathname
  
  'test controller getting served correct view': ->
    mainViewFromController = undefined
    
    MyApp = Wingman.Application.extend()
    MyApp.RootController = Wingman.Controller.extend()
    MyApp.RootView = Wingman.View.extend
      templateSource: "{view 'main'}"
    
    MyApp.MainController = Wingman.Controller.extend
      ready: ->
        mainViewFromController = @view
      
    MyApp.MainView = ViewWithTemplateSource.extend()
    
    app = MyApp.create()
    @assert mainViewFromController instanceof MyApp.MainView
  
  'test nested controller getting served correct view': ->
    viewFromMainController = undefined
    
    MyApp = Wingman.Application.extend()
    MyApp.RootController = Wingman.Controller.extend()
    MyApp.MainController = ControllerWithView.extend()
    MyApp.MainController.UserController = Wingman.Controller.extend
      ready: ->
        viewFromMainController = @view
    
    MyApp.RootView = Wingman.View.extend
      templateSource: "{view 'main'}"
    
    MyApp.MainView = Wingman.View.extend
      templateSource: "{view 'user'}"
    
    MyApp.MainView.UserView = ViewWithTemplateSource.extend()
    
    app = MyApp.create el: Wingman.document.createElement('div')
    @assert viewFromMainController instanceof MyApp.MainView.UserView
  
  'test passing correct view classes': ->
    MyApp = Wingman.Application.extend()
    MyApp.RootController = Wingman.Controller.extend()
    MyApp.RootView = ViewWithTemplateSource.extend()
    MyApp.MainView = ViewWithTemplateSource.extend()
    rootViewSiblings = MyApp.rootViewSiblings()
    
    @assert rootViewSiblings.MainView
    @assert !rootViewSiblings.RootController
    @assert !rootViewSiblings.RootView
  
  'test using document.body as default parent': ->
    MyApp = Wingman.Application.extend()
    MyApp.RootView = Wingman.View.extend
      templateSource: '<div>hello</div>'
    
    MyApp.create()
    @assertEqual '<div>hello</div>', Wingman.document.body.innerHTML
