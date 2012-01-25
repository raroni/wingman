Janitor = require 'janitor'
Wingman = require '../../.'
JSDomWindowPopStateDecorator = require '../jsdom_window_pop_state_decorator'

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

module.exports = class extends Janitor.TestCase
  setup: ->
    Wingman.document = require('jsdom').jsdom()
    Wingman.window = JSDomWindowPopStateDecorator.create(Wingman.document.createWindow())
    
  'test automatic children instantiation': ->
    App = class extends Wingman.App
    App.RootView = class extends Wingman.View
      templateSource: -> '{view user}'
    
    App.RootController = class extends Wingman.Controller
    App.UserController = class extends Wingman.Controller
    App.UserView = class extends Wingman.View
      templateSource: -> '<div>stubbing the source</div>'
    
    root_el = Wingman.document.createElement 'div'
    app = new App el: root_el
    @assert root_el.innerHTML.match('stubbing the source')

  'test session': ->
    App = class extends Wingman.App
    App.RootView = class extends ViewWithTemplateSource
    App.RootController = class extends Wingman.Controller

    root_el = Wingman.document.createElement 'div'
    app = new App el: root_el
    app.session.set user_id: 27
    @assertEqual 27, app.session.get('user_id')

  'test session sharing': ->
    App = class extends Wingman.App
    App.RootController = class extends Wingman.Controller
    App.RootView = class extends ViewWithTemplateSource
    App.UserController = class extends Wingman.Controller
    App.UserView = class extends ViewWithTemplateSource
    
    root_el = Wingman.document.createElement 'div'
    app = new App el: root_el
    @assertEqual app.session, app.view.get('user.session')
    @assertEqual app.session, app.controller.get('user.session')
    
    app.controller.get('user.session').set user_id: 2
    @assertEqual 2, app.session.get('user_id')
  
  'test singleton instance': ->
    class MyApp extends Wingman.App
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
    
    @assert !Wingman.App.instance
    new MyApp el: Wingman.document.createElement 'div'
    @assert Wingman.App.instance
  
  'test instantiation of two apps': ->
    class MyApp extends Wingman.App
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
    
    app_options = { el: Wingman.document.createElement('div') }
    new MyApp app_options
    @assertThrows -> new App app_options
  
  'test reading config params on applications instance': ->
    class MyApp extends Wingman.App
      host: 'test-host.com'
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
    
    new MyApp el: Wingman.document.createElement('div')
    
    @assertEqual 'test-host.com', Wingman.App.instance?.host
  
  'test ready callback': ->
    callback_fired = false
    MyApp = class extends Wingman.App
      ready: ->
        callback_fired = true
    
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
    
    root_view = new ViewWithTemplateSource
    app = new MyApp el: Wingman.document.createElement('div')
    @assert callback_fired
  
  'test simple routing': ->
    MyApp = class extends Wingman.App
      one_child_at_a_time: true
      routes:
        'user': 'user'
    
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
    MyApp.UserController = class extends Wingman.Controller
    MyApp.UserView = class extends ViewWithTemplateSource
    MyApp.MailController = class extends Wingman.Controller
    MyApp.MailView = class extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement('div')
    app.navigate 'user'
    @assert app.controller.get('user').is_active
    @assertEqual false, app.controller.get('mail').is_active
  
  'test initial route': ->
    MyApp = class extends Wingman.App
      one_child_at_a_time: true
      routes:
        '': 'main'
        'user': 'user'
    
    MyApp.RootController = class extends Wingman.Controller
    MyApp.MainController = class extends Wingman.Controller
    MyApp.UserController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
    MyApp.MainView = class extends ViewWithTemplateSource
    MyApp.UserView = class extends ViewWithTemplateSource
    
    Wingman.window.document.location.pathname = '/user'
    app = new MyApp el: Wingman.document.createElement('div')
    @assert app.controller.get('user').is_active
  
  'test route to nested controller': ->
    MyApp = class extends Wingman.App
      one_child_at_a_time: true
      routes:
        'test': 'main.sub'
    
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends ViewWithTemplateSource
    
    MyApp.MainController = class extends ControllerWithView
      one_child_at_a_time: true
    
    MyApp.MainController.SubController = class extends ControllerWithView
    MyApp.MainController.SubView = class extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement('div')
    app.navigate 'test'
    @assert app.controller.get('main.sub').is_active
  
  'test controller finding matching view automatically': ->
    MyApp = class extends Wingman.App
      @one_child_at_a_time: true
    
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends Wingman.View
      templateSource: -> '{view main}'
    
    MyApp.MainController = class extends Wingman.Controller
    MyApp.MainView = class extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement('div')
    @assert app.controller.get('main').view instanceof MyApp.MainView
    
  'test nested controllers finding matching view automatically': ->
    Wingman.View.template_sources = { 'root': '{view main}' }
    
    MyApp = class extends Wingman.App
    MyApp.RootController = class extends Wingman.Controller
    MyApp.RootView = class extends Wingman.View
      templateSource: -> '{view main}'
    MyApp.MainController = class extends ControllerWithView
    MyApp.MainController.UserController = class extends Wingman.Controller
    MyApp.MainView = class extends ViewWithTemplateSource
    MyApp.MainView.UserView = class extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement('div')
    @assert app.controller.get('main.user').view instanceof MyApp.MainView.UserView
    
  teardown: ->
    delete Wingman.App.instance
    Wingman.View.template_sources = {}
