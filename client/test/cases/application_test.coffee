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
  
  'test session': ->
    class App extends Wingman.Application
    class App.RootView extends ViewWithTemplateSource
    class App.RootController extends Wingman.Controller
  
    root_el = Wingman.document.createElement 'div'
    app = new App el: root_el
    app.session.set user_id: 27
    @assertEqual 27, app.session.get('user_id')
   
  'test session sharing': ->
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends Wingman.View
      templateSource: -> "{view user}"
    class MyApp.UserController extends Wingman.Controller
      ready: ->
        @get('session').set controller_greeting: 'Controller says hello'
    
    class MyApp.UserView extends ViewWithTemplateSource
      ready: ->
        @get('session').set view_greeting: 'View says hello'
    
    root_el = Wingman.document.createElement 'div'
    app = new MyApp el: root_el
    
    @assertEqual 'View says hello', app.session.get('view_greeting')
    @assertEqual 'Controller says hello', app.session.get('controller_greeting')
  
  'test shared context object': ->
    class App extends Wingman.Application
    class App.RootView extends ViewWithTemplateSource
    class App.RootController extends Wingman.Controller
    
    root_el = Wingman.document.createElement 'div'
    app = new App el: root_el
    app.shared.set user_id: 28
    @assertEqual 28, app.shared.get('user_id')
  
  'test sharing of shared context object': ->
    class App extends Wingman.Application
    class App.RootController extends Wingman.Controller
    class App.RootView extends Wingman.View
      templateSource: -> "{view user}"
    
    class App.UserController extends Wingman.Controller
      ready: ->
        @get('shared').set controller_greeting: 'Controller says hello'
    
    class App.UserView extends ViewWithTemplateSource
      ready: ->
        @get('shared').set view_greeting: 'View says hello'
    
    root_el = Wingman.document.createElement 'div'
    app = new App el: root_el
    @assertEqual 'View says hello', app.shared.get('view_greeting')
    @assertEqual 'Controller says hello', app.shared.get('controller_greeting')
  
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
  
  'test navigate and session': ->
    class MyApp extends Wingman.Application
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement 'div'
    app.navigate 'user'
    @assertEqual 'user', app.shared.get('path')
  
  'test initial path': ->
    MyApp = class extends Wingman.Application
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
    
    Wingman.window.document.location.pathname = '/user'
    app = new MyApp el: Wingman.document.createElement('div')
    @assertEqual 'user', app.shared.get('path')
  
  'test backing through history': ->
    class MyApp extends Wingman.Application
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
  
    app = new MyApp el: Wingman.document.createElement 'div'
    app.navigate 'user'
    app.navigate 'home'
    app.back()
    @assertEqual 'user', app.shared.get('path')
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
  
  'test automatic session load after init': ->
    Wingman.localStorage.setItem "sessions.1", JSON.stringify({ user_id: 1 })
    MyApp = class extends Wingman.Application
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
    app = new MyApp el: Wingman.document.createElement('div')
    @assertEqual 1, app.session.get('user_id')
  
  'test setting correct classes on RootView': ->
    class MyApp extends Wingman.Application
    class MyApp.RootController extends Wingman.Controller
    class MyApp.RootView extends ViewWithTemplateSource
    class MyApp.MainView extends ViewWithTemplateSource
    new MyApp el: Wingman.document.createElement('div') 
    @assertEqual MyApp.MainView, MyApp.RootView.MainView
    @assert !MyApp.RootView.RootController
  
  teardown: ->
    delete Wingman.Application.instance
    Wingman.View.template_sources = {}
