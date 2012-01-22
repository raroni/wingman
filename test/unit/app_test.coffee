Janitor = require 'janitor'
Wingman = require '../../.'
JSDomWindowPopStateDecorator = require '../jsdom_window_pop_state_decorator'

Wingman.View.template_sources = {
  'user': '<div>stubbing the source</div>'
  'main': '<div>stubbing the source</div>'
}

module.exports = class extends Janitor.TestCase
  setup: ->
    Wingman.document = require('jsdom').jsdom()
    Wingman.window = JSDomWindowPopStateDecorator.create(Wingman.document.createWindow())
    
  'test automatic children instantiation': ->
    App = class extends Wingman.App
    App.UserController = class extends Wingman.Controller
    App.UserView = class extends Wingman.View
    
    root_el = Wingman.document.createElement 'div'
    app = new App el: root_el
    
    @assert root_el.innerHTML.match('stubbing the source')
  
  'test singleton instance': ->
    class MyApp extends Wingman.App
    el = Wingman.document.createElement 'div'
    @assert !Wingman.App.instance
    new MyApp {el}
    @assert Wingman.App.instance
  
  'test instantiation of two apps': ->
    class MyApp extends Wingman.App
    el = Wingman.document.createElement 'div'
    new MyApp {el}
    @assertThrows -> new App {el}
  
  'test reading config params on applications instance': ->
    class MyApp extends Wingman.App
      host: 'test-host.com'
      
    new MyApp el: Wingman.document.createElement 'div'
    
    @assertEqual 'test-host.com', Wingman.App.instance?.host
  
  'test ready callback': ->
    callback_fired = false
    App = class extends Wingman.App
      ready: ->
        callback_fired = true
        
    app = new App el: Wingman.document.createElement('div')
    @assert callback_fired

  'test simple routing': ->
    user_controller_activated = false
    
    App = class extends Wingman.App
      routes:
        'user': 'user'
    
    App.UserController = class extends Wingman.Controller
      activate: ->
        user_controller_activated = true
    
    App.UserView = class extends Wingman.View
        
    app = new App el: Wingman.document.createElement('div')
    app.navigate 'user'
    @assert user_controller_activated

  'test initial route': ->
    main_controller_activated = false

    App = class extends Wingman.App
      routes:
        '': 'main'

    App.MainController = class extends Wingman.Controller
      activate: ->
        main_controller_activated = true

    App.MainView = class extends Wingman.View

    app = new App el: Wingman.document.createElement('div')
    @assert main_controller_activated
  
  teardown: ->
    delete Wingman.App.instance
