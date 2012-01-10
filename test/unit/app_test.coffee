Janitor = require 'janitor'
Wingman = require '../../.'
Wingman.document = require('jsdom').jsdom()

module.exports = class extends Janitor.TestCase
  'test automatic setup': ->
    Wingman.View.template_sources = {
      'user': '<div>stubbing the source</div>'
    }
    
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
  
  teardown: ->
    delete Wingman.App.instance