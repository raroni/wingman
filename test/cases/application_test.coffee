Janitor = require 'janitor'
Wingman = require '../../.'
JSDomWindowPopStateDecorator = require '../jsdom_window_pop_state_decorator'
Wingman.localStorage = require 'localStorage'

Wingman.View.template_sources = {
  'user': '<div>stubbing the source</div>'
  'main': '<div>stubbing the source</div>'
}

class ViewWithTemplateSource extends Wingman.View
  templateSource: -> '<div>test</div>'

class ControllerWithView extends Wingman.Controller
  constructor: (options = {}) ->
    options.view = new ViewWithTemplateSource parent: { el: Wingman.document.createElement('div') }
    super options

module.exports = class ApplicationTest extends Janitor.TestCase
  setup: ->
    Wingman.document = require('jsdom').jsdom()
    Wingman.window = JSDomWindowPopStateDecorator.create(Wingman.document.createWindow())
  
  'test most basic application': ->
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends Wingman.View
      templateSource: -> '<div>Hi</div>'
    app = new MyApp el: Wingman.document.createElement('div')
    @assert '<div>Hi</div>', app.el.innerHTML
  
  'test simple child view': ->
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.UserController extends Wingman.Controller
    
    class MyApp.RootView extends Wingman.View
      templateSource: -> '{view user}'
    
    class MyApp.UserView extends Wingman.View
      templateSource: -> '<div>stubbing the source</div>'
    
    root_el = Wingman.document.createElement 'div'
    app = new MyApp el: root_el
    @assert root_el.innerHTML.match('stubbing the source')

  'test access to application instance': ->
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends Wingman.View
      templateSource: -> "{view user}"
    class MyApp.UserController extends Wingman.Controller
      ready: ->
        @get('app').set controller_greeting: 'Controller says hello'
    
    class MyApp.UserView extends ViewWithTemplateSource
      ready: ->
        @get('app').set view_greeting: 'View says hello'
    
    root_el = Wingman.document.createElement 'div'
    app = new MyApp el: root_el
    
    @assertEqual 'View says hello', app.get('view_greeting')
    @assertEqual 'Controller says hello', app.get('controller_greeting')
  
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
    
    app_options = { el: Wingman.document.createElement('div') }
    new MyApp app_options
    @assertThrows -> new App app_options
  
  'test reading config params on applications instance': ->
    class MyApp extends Wingman.Application
      host: 'test-host.com'
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
    
    new MyApp el: Wingman.document.createElement('div')
    
    @assertEqual 'test-host.com', Wingman.Application.instance?.host
  
  'test application ready callback': ->
    callback_fired = false
    
    class MyApp extends Wingman.Application
      ready: -> callback_fired = true
    
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement('div')
    @assert callback_fired
  
  'test root controller callback': ->
    callback_fired = false
    
    class MyApp extends Wingman.Application
    class MyApp.RootView extends ViewWithTemplateSource
    class MyApp.RootController extends Wingman.Controller
      ready: ->
        callback_fired = true
    
    new MyApp el: Wingman.document.createElement('div')
    @assert callback_fired
  
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
    @assertEqual 2, app.get('navigation_options.level')
  
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
    main_view_from_controller = undefined
    
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends Wingman.View
      templateSource: -> '{view main}'
    
    class MyApp.MainController extends Wingman.Controller
      ready: ->
        main_view_from_controller = @view
      
    class MyApp.MainView extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement('div')
    @assert main_view_from_controller instanceof MyApp.MainView
  
  'test nested controller getting served correct view': ->
    view_from_main_controller = undefined
    
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.MainController extends ControllerWithView
    class MyApp.MainController.UserController extends Wingman.Controller
      ready: -> view_from_main_controller = @view
    
    class MyApp.RootView extends Wingman.View
      templateSource: -> '{view main}'
    
    class MyApp.MainView extends Wingman.View
      templateSource: -> '{view user}'
    
    class MyApp.MainView.UserView extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement('div')
    @assert view_from_main_controller instanceof MyApp.MainView.UserView
  
  'test setting correct classes on RootView': ->
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends ViewWithTemplateSource
    class MyApp.MainView extends ViewWithTemplateSource
    new MyApp el: Wingman.document.createElement('div') 
    @assertEqual MyApp.MainView, MyApp.RootView.MainView
    @assert !MyApp.RootView.RootController
  
  'test view depending on properties of shared': ->
    callback_fired = false
    
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends ViewWithTemplateSource
      @propertyDependencies
        someMethod: 'app.test'
      
      someMethod: ->
        callback_fired = true
    
    app = new MyApp el: Wingman.document.createElement('div')
    @assert callback_fired # fired because root_view's shared is set during its constructor
    callback_fired = false
    app.set test: 'something'
    @assert callback_fired
    
  'test controller depending on properties of shared': ->
    callback_fired = false
    
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
      @propertyDependencies
        someMethod: 'app.test'
      
      someMethod: ->
        callback_fired = true
    
    class MyApp.RootView extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement('div')
    @assert callback_fired # fired because root_controller's shared is set during its constructor
    callback_fired = false
    app.set test: 'something'
    @assert callback_fired
  
  teardown: ->
    delete Wingman.Application.instance
    Wingman.View.template_sources = {}
