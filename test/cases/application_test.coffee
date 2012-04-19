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
  constructor: (options = {}) ->
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
    class MyApp extends Wingman.Application
    class MyApp.RootView extends Wingman.View
      templateSource: '<div>Hi</div>'
    
    app = new MyApp el: Wingman.document.createElement('div')
    @assertEqual '<div>Hi</div>', app.el.innerHTML
  
  'test simple child view': ->
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.UserController extends Wingman.Controller
    
    class MyApp.RootView extends Wingman.View
      templateSource: "{view 'user'}"
    
    class MyApp.UserView extends Wingman.View
      templateSource: '<div>stubbing the source</div>'
    
    rootEl = Wingman.document.createElement 'div'
    app = new MyApp el: rootEl
    @assert rootEl.innerHTML.match('stubbing the source')
  
  'test access to application instance': ->
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends Wingman.View
      templateSource: "{view 'user'}"
    class MyApp.UserController extends Wingman.Controller
      ready: ->
        @get('app').set controllerGreeting: 'Controller says hello'
    
    class MyApp.UserView extends ViewWithTemplateSource
      ready: ->
        @get('app').set viewGreeting: 'View says hello'
    
    rootEl = Wingman.document.createElement 'div'
    app = new MyApp el: rootEl
    
    @assertEqual 'View says hello', app.get('viewGreeting')
    @assertEqual 'Controller says hello', app.get('controllerGreeting')
  
  'test singleton instance': ->
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends ViewWithTemplateSource
    
    @assert !Wingman.Application.instance
    new MyApp el: Wingman.document.createElement 'div'
    @assert Wingman.Application.instance
  
  'test instantiation of two apps': ->
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends ViewWithTemplateSource
    
    appOptions = { el: Wingman.document.createElement('div') }
    new MyApp appOptions
    @assertThrows -> new App appOptions
  
  'test reading config params on applications instance': ->
    class MyApp extends Wingman.Application
      host: 'test-host.com'
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
    
    new MyApp el: Wingman.document.createElement('div')
    
    @assertEqual 'test-host.com', Wingman.Application.instance?.host
  
  'test application ready callback': ->
    callbackFired = false
    
    class MyApp extends Wingman.Application
      ready: -> callbackFired = true
    
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement('div')
    @assert callbackFired
  
  'test root controller callback': ->
    callbackFired = false
    
    class MyApp extends Wingman.Application
    class MyApp.RootView extends ViewWithTemplateSource
    class MyApp.RootController extends Wingman.Controller
      ready: ->
        callbackFired = true
    
    new MyApp el: Wingman.document.createElement('div')
    @assert callbackFired
  
  'test navigate and shared path': ->
    class MyApp extends Wingman.Application
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement 'div'
    app.navigate 'user'
    @assertEqual 'user', app.get('path')
  
  'test navigation options': ->
    class MyApp extends Wingman.Application
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
  
    app = new MyApp el: Wingman.document.createElement 'div'
    app.navigate 'user', level: 2
    @assertEqual 'user', app.get('path')
    @assertEqual 2, app.get('navigationOptions.level')
  
  'test initial path': ->
    MyApp = class extends Wingman.Application
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
    
    Wingman.window.document.location.pathname = '/user'
    app = new MyApp el: Wingman.document.createElement('div')
    @assertEqual 'user', app.get('path')
  
  'test backing through history': ->
    class MyApp extends Wingman.Application
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
  
    app = new MyApp el: Wingman.document.createElement 'div'
    app.navigate 'user'
    app.navigate 'home'
    app.back()
    @assertEqual 'user', app.get('path')
    @assertEqual '/user', Wingman.window.location.pathname
  
  'test controller getting served correct view': ->
    mainViewFromController = undefined
    
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends Wingman.View
      templateSource: "{view 'main'}"
    
    class MyApp.MainController extends Wingman.Controller
      ready: ->
        mainViewFromController = @view
      
    class MyApp.MainView extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement('div')
    @assert mainViewFromController instanceof MyApp.MainView
  
  'test nested controller getting served correct view': ->
    viewFromMainController = undefined
    
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.MainController extends ControllerWithView
    class MyApp.MainController.UserController extends Wingman.Controller
      ready: -> viewFromMainController = @view
    
    class MyApp.RootView extends Wingman.View
      templateSource: "{view 'main'}"
    
    class MyApp.MainView extends Wingman.View
      templateSource: "{view 'user'}"
    
    class MyApp.MainView.UserView extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement('div')
    @assert viewFromMainController instanceof MyApp.MainView.UserView
  
  'test passing correct view classes': ->
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends ViewWithTemplateSource
    class MyApp.MainView extends ViewWithTemplateSource
    rootViewSiblings = MyApp.rootViewSiblings()
    
    @assert rootViewSiblings.MainView
    @assert !rootViewSiblings.RootController
    @assert !rootViewSiblings.RootView
  
  'test view depending on properties of shared': ->
    callbackFired = false
    
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends ViewWithTemplateSource
      @propertyDependencies
        someMethod: 'app.test'
      
      someMethod: ->
        callbackFired = true
    
    app = new MyApp el: Wingman.document.createElement('div')
    app.set test: 'something'
    @assert callbackFired
    
  'test controller depending on properties of shared': ->
    callbackFired = false
    
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
      @propertyDependencies
        someMethod: 'app.test'
      
      someMethod: ->
        callbackFired = true
    
    class MyApp.RootView extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement('div')
    app.set test: 'something'
    @assert callbackFired
  
  'test view without corresponding controller': ->
    class MyApp extends Wingman.Application
    class MyApp.RootView extends ViewWithTemplateSource
    @refuteThrows -> new MyApp el: Wingman.document.createElement('div')
  
  'test using document.body as default parent': ->
    class MyApp extends Wingman.Application
    class MyApp.RootView extends Wingman.View
      templateSource: '<div>hello</div>'
    
    new MyApp
    @assertEqual '<div>hello</div>', Wingman.document.body.innerHTML
