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
    
    App.UserController = class extends Wingman.Controller
    App.UserView = class extends Wingman.View
      templateSource: -> '<div>stubbing the source</div>'
    
    root_el = Wingman.document.createElement 'div'
    app = new App el: root_el
    @assert root_el.innerHTML.match('stubbing the source')
  
  'test singleton instance': ->
    class MyApp extends Wingman.App
    el = Wingman.document.createElement 'div'
    @assert !Wingman.App.instance
    
    root_view = new ViewWithTemplateSource
    new MyApp view: root_view
    @assert Wingman.App.instance
  
  'test instantiation of two apps': ->
    class MyApp extends Wingman.App
    root_view = new ViewWithTemplateSource
    app_options = { view: root_view }
    new MyApp app_options
    @assertThrows -> new App
  
  'test reading config params on applications instance': ->
    class MyApp extends Wingman.App
      host: 'test-host.com'
    
    root_view = new ViewWithTemplateSource
    new MyApp view: root_view
    
    @assertEqual 'test-host.com', Wingman.App.instance?.host
  
  'test ready callback': ->
    callback_fired = false
    App = class extends Wingman.App
      ready: ->
        callback_fired = true
    
    root_view = new ViewWithTemplateSource
    app = new App view: root_view
    @assert callback_fired
  
  'test simple routing': ->
    App = class extends Wingman.App
      one_child_at_a_time: true
      routes:
        'user': 'user'
    
    App.UserController = class extends Wingman.Controller
    App.UserView = class extends ViewWithTemplateSource
    App.MailController = class extends Wingman.Controller
    App.MailView = class extends ViewWithTemplateSource
    App.RootView = class extends ViewWithTemplateSource
    
    app = new App el: Wingman.document.createElement('div')
    app.navigate 'user'
    
    @assert app.controllers.get('user').is_active
    @assertEqual false, app.controllers.get('mail').is_active
  
  'test initial route': ->
    App = class extends Wingman.App
      one_child_at_a_time: true
      routes:
        '': 'main'
    
    App.MainController = class extends Wingman.Controller
    App.MainView = class extends ViewWithTemplateSource
    App.RootView = class extends ViewWithTemplateSource
  
    app = new App el: Wingman.document.createElement('div')
    @assert app.controllers.get('main').is_active
  
  'test route to nested controller': ->
    App = class extends Wingman.App
      one_child_at_a_time: true
      routes:
        'test': 'main.sub'
  
    App.MainController = class extends ControllerWithView
      one_child_at_a_time: true
    App.MainController.SubController = class extends ControllerWithView
    App.MainController.SubView = class extends Wingman.View
      templateSource: -> '<div>test</div>'
    
    root_view = new ViewWithTemplateSource
    app = new App view: root_view
    app.navigate 'test'
    @assert app.controllers.get('main.sub').is_active
  
  'test controller finding matching view automatically': ->
    MyApp = class extends Wingman.App
      @one_child_at_a_time: true
    MyApp.RootView = class extends Wingman.View
      templateSource: -> '{view main}'
    MyApp.MainController = class extends Wingman.Controller
    MyApp.MainView = class extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement('div')
    @assert app.controllers.get('main').view instanceof MyApp.MainView
    
  'test nested controllers finding matching view automatically': ->
    Wingman.View.template_sources = { 'root': '{view main}' }
    
    MyApp = class extends Wingman.App
    MyApp.RootView = class extends Wingman.View
      templateSource: -> '{view main}'
    MyApp.MainController = class extends ControllerWithView
    MyApp.MainController.UserController = class extends Wingman.Controller
    MyApp.MainView = class extends ViewWithTemplateSource
    MyApp.MainView.UserView = class extends ViewWithTemplateSource
    
    app = new MyApp el: Wingman.document.createElement('div')
    @assert app.controllers.get('main.user').view instanceof MyApp.MainView.UserView
    
  teardown: ->
    delete Wingman.App.instance
    Wingman.View.template_sources = {}
