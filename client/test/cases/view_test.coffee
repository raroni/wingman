Janitor = require 'janitor'
Wingman = require '../../.'
WingmanObject = require '../../lib/wingman-client/shared/object'
View = Wingman.View
document = require('jsdom').jsdom(null, null, features: {
        QuerySelector : true
      })

ViewWithTemplateSource = class extends View
  templateSource: -> '<div>test</div>'

clickElement = (elm) ->
  event = document.createEvent "MouseEvents"
  event.initMouseEvent "click", true, true
  elm.dispatchEvent event

module.exports = class ViewTest extends Janitor.TestCase
  setup: ->
    Wingman.document = document
    View.template_sources = {}
  
  'test simple template': ->
    View.template_sources.main = '<div>hello</div>'
    class MainView extends View
    
    dummy_app =
      pathKeys: -> []
      el: document.createElement('div')
    
    view = new MainView parent: dummy_app, render: true
    @assertEqual 1, view.el.childNodes.length
    @assertEqual 'hello', view.el.childNodes[0].innerHTML
    
  'test setting dom class': ->
    class UserView extends View
      templateSource: -> '<div>hello</div>'
  
    view = new UserView render: true
    @assertEqual 'user', view.el.className
  
  'test simple template with dynamic values': ->
    View.template_sources.simple_with_dynamic_values = '<div>{myName}</div>'
    class SimpleWithDynamicValuesView extends View
  
    dummy_app =
      pathKeys: -> []
      el: document.createElement('div')
  
    view = new SimpleWithDynamicValuesView parent: dummy_app, render: true
    view.set myName: 'Razda'
    @assertEqual 1, view.el.childNodes.length
    @assertEqual 'Razda', view.el.childNodes[0].innerHTML
  
  'test parse events': ->
    events_hash =
      'click .user': 'user_clicked'
      'hover button.some_class': 'button_hovered'
      
    events = View.parseEvents(events_hash).sort (e1, e2) -> e1.type > e2.type
    
    @assertEqual 'click', events[0].type
    @assertEqual 'user_clicked', events[0].trigger
    @assertEqual '.user', events[0].selector
    
    @assertEqual 'hover', events[1].type
    @assertEqual 'button_hovered', events[1].trigger
    @assertEqual 'button.some_class', events[1].selector
  
  'test simple event': ->
    View.template_sources.main = '<div><div class="user">Johnny</div></div>'
    class MainView extends View
      @_name: 'test'
      events:
        'click .user': 'user_clicked'
    
    dummy_app =
      pathKeys: -> []
      el: document.createElement('div')
    
    view = new MainView parent: dummy_app, render: true
    clicked = false
    view.bind 'user_clicked', ->
      clicked = true
    
    clickElement view.el.childNodes[0].childNodes[0]
    @assert clicked
    
  'test click on views mother element': ->
    event_from_callback = undefined
    did_maintain_context = false
    class MainView extends View
      randomProperty: true
      click: (event) ->
        did_maintain_context = @randomProperty
        event_from_callback = event
      templateSource: -> '<div><a>BOING</a></div>'
    
    view = new MainView render: true
    clickElement view.el.childNodes[0].childNodes[0]
    @assert event_from_callback
    @assertEqual 'A', event_from_callback.target.tagName
    @assert did_maintain_context
  
  'test trigger arguments': ->
    View.template_sources.main = '<div>Something</div>'
    class MainView extends View
      @_name: 'test'
      events:
        'click div': 'something_happened'
      
      somethingHappenedArguments: ->
        ['a', 'b']
    
    dummy_app =
      pathKeys: -> []
      el: document.createElement('div')
    
    view = new MainView parent: dummy_app, render: true
    a = null
    b = null
    view.bind 'something_happened', (x,y) ->
      a = x
      b = y
    
    clickElement view.el.childNodes[0]
    @assertEqual 'a', a
    @assertEqual 'b', b
  
  'test path of deeply nested view': ->
    class MainView extends ViewWithTemplateSource
      isRoot: -> true
    class MainView.UserView extends ViewWithTemplateSource
    class MainView.UserView.NameView extends ViewWithTemplateSource
    class MainView.UserView.NameView.FirstView extends ViewWithTemplateSource
    
    main = new MainView parent: { el: document.createElement('div') }, render: true
    user = main.createChildView 'user'
    name = user.createChildView 'name'
    first = name.createChildView 'first'
    @assertEqual 'user.name.first', first.path()
  
  'test show/hide via isActive': ->
    LoggedInView = class extends ViewWithTemplateSource
      @propertyDependencies
        isActive: ['logged_in']
      
      isActive: ->
        @get 'logged_in'
    
    view = new LoggedInView render: true
    @assertEqual 'none', view.el.style.display
    view.set logged_in: true
    @assertEqual '', view.el.style.display
    view.set logged_in: false
    @assertEqual 'none', view.el.style.display
  
  'test show/hide via isActive using nested properties': ->
    LoggedInView = class extends ViewWithTemplateSource
      @propertyDependencies
        isActive: ['session.user_id']
    
      isActive: ->
        @get 'session.user_id'
    
    view = new LoggedInView render: true
    session = new WingmanObject
    view.set { session }
    @assertEqual 'none', view.el.style.display
    session.set user_id: 2
    @assertEqual '', view.el.style.display
    session.set user_id: null
    @assertEqual 'none', view.el.style.display
  
  'test show/hide via isActive when isActive is not implemented': ->
    SomeView = class extends ViewWithTemplateSource
    view = new SomeView render: true
    @assertEqual undefined, view.el.style.display
  
  'test session sharing': ->
    class MainView extends ViewWithTemplateSource
    class MainView.UserView extends ViewWithTemplateSource
    class MainView.UserView.NameView extends ViewWithTemplateSource
    
    session = new WingmanObject
    view = new MainView { session, render: true }
    @assertEqual session, view.createChildView('user').createChildView('name').get('session')
  
  'test sharing of shared context object': ->
    class MainView extends ViewWithTemplateSource
    class MainView.UserView extends ViewWithTemplateSource
    class MainView.UserView.NameView extends ViewWithTemplateSource
    
    shared = new WingmanObject
    view = new MainView { shared, render: true }
    @assertEqual shared, view.createChildView('user').createChildView('name').get('shared')
  
  'test access to parent': ->
    class MainView extends ViewWithTemplateSource
    class MainView.UserView extends ViewWithTemplateSource
    class MainView.UserView.NameView extends ViewWithTemplateSource
    
    view = new MainView render: true
    @assert view.createChildView('user').createChildView('name').get('parent.parent') instanceof MainView
    
  'test ready callback': ->
    callback_fired = false
    class MainView extends ViewWithTemplateSource
      ready: -> callback_fired = true
    
    view = new MainView render: true
    @assert callback_fired
  
  'test build sub view': ->
    class MainView extends ViewWithTemplateSource
    class MainView.UserView extends ViewWithTemplateSource
    
    view = new MainView render: true
    sub_view = view.createChildView 'user'
    @assert sub_view instanceof MainView.UserView
    @assert view, sub_view.parent
  
  'test descendant view event': ->
    class MainView extends ViewWithTemplateSource
    class MainView.UserView extends ViewWithTemplateSource
    class MainView.UserView.NameView extends ViewWithTemplateSource
    
    main = new MainView
    callback_values = []
    main.bind 'descendantCreated', (view) -> callback_values.push view
    user = main.createChildView('user')
    name = user.createChildView('name')
    
    @assertEqual 2, callback_values.length
    @assertEqual user, callback_values[0]
    @assertEqual name, callback_values[1]
  
  'test custom tag': ->
    class MainView extends ViewWithTemplateSource
      tag: 'tr'
    
    main_view = new MainView render: true
    @assertEqual 'TR', main_view.el.tagName
