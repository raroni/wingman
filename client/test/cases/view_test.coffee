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
    View.template_sources.simple = '<div>hello</div>'
    ViewKlass = class MainView extends View
      @_name: 'simple'
    
    dummy_app =
      pathKeys: -> []
      el: document.createElement('div')
    
    view = new ViewKlass parent: dummy_app
    @assertEqual 1, view.el.childNodes.length
    @assertEqual 'hello', view.el.childNodes[0].innerHTML
    
  'test setting dom class': ->
    UserView = class extends View
      @_name: 'user'
      templateSource: -> '<div>hello</div>'
  
    view = new UserView
    @assertEqual 'user', view.el.className
  
  'test simple template with dynamic values': ->
    View.template_sources.simple_with_dynamic_values = '<div>{myName}</div>'
    ViewKlass = class MainView extends View
      @_name: 'simple_with_dynamic_values'
  
    dummy_app =
      pathKeys: -> []
      el: document.createElement('div')
  
    view = new ViewKlass parent: dummy_app
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
    View.template_sources.test = '<div><div class="user">Johnny</div></div>'
    ViewKlass = class MainView extends View
      @_name: 'test'
      events:
        'click .user': 'user_clicked'
    
    dummy_app =
      pathKeys: -> []
      el: document.createElement('div')
    
    view = new ViewKlass parent: dummy_app
    clicked = false
    view.bind 'user_clicked', ->
      clicked = true
    
    clickElement view.el.childNodes[0].childNodes[0]
    @assert clicked
    
  'test click on views mother element': ->
    event_from_callback = undefined
    did_maintain_context = false
    ViewKlass = class MainView extends View
      randomProperty: true
      click: (event) ->
        did_maintain_context = @randomProperty
        event_from_callback = event
      templateSource: -> '<div><a>BOING</a></div>'
  
    view = new ViewKlass
    clickElement view.el.childNodes[0].childNodes[0]
    @assert event_from_callback
    @assertEqual 'A', event_from_callback.target.tagName
    @assert did_maintain_context
  
  'test trigger arguments': ->
    View.template_sources.test = '<div>Something</div>'
    ViewKlass = class MainView extends View
      @_name: 'test'
      events:
        'click div': 'something_happened'
      
      somethingHappenedArguments: ->
        ['a', 'b']
    
    dummy_app =
      pathKeys: -> []
      el: document.createElement('div')
    
    view = new ViewKlass parent: dummy_app
    a = null
    b = null
    view.bind 'something_happened', (x,y) ->
      a = x
      b = y
    
    clickElement view.el.childNodes[0]
    @assertEqual 'a', a
    @assertEqual 'b', b
  
  'test path of deeply nested view': ->
    MainView = class extends ViewWithTemplateSource
    MainView.UserView = class extends ViewWithTemplateSource
    MainView.UserView.NameView = class extends ViewWithTemplateSource
    MainView.UserView.NameView.FirstView = class extends ViewWithTemplateSource
    
    view = new MainView parent: { el: document.createElement('div') }
    @assertEqual 'user_view.name_view.first_view', view.get('user_view.name_view.first_view').path()
  
  'test show/hide via isActive': ->
    LoggedInView = class extends ViewWithTemplateSource
      @propertyDependencies
        isActive: ['logged_in']
      
      isActive: ->
        @get 'logged_in'
    
    view = new LoggedInView
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
    
    view = new LoggedInView
    session = new WingmanObject
    view.set { session }
    @assertEqual 'none', view.el.style.display
    session.set user_id: 2
    @assertEqual '', view.el.style.display
    session.set user_id: null
    @assertEqual 'none', view.el.style.display
  
  'test show/hide via isActive when isActive is not implemented': ->
    SomeView = class extends ViewWithTemplateSource
    view = new SomeView
    @assertEqual undefined, view.el.style.display
  
  'test session sharing': ->
    MainView = class extends ViewWithTemplateSource
    MainView.UserView = class extends ViewWithTemplateSource
    MainView.UserView.NameView = class extends ViewWithTemplateSource
    MainView.UserView.NameView.FirstView = class extends ViewWithTemplateSource
    
    session = new WingmanObject
    view = new MainView children: { options: { session} }
    @assertEqual session, view.get('user_view.name_view.session')
  
  'test sharing of shared context object': ->
    MainView = class extends ViewWithTemplateSource
    MainView.UserView = class extends ViewWithTemplateSource
    MainView.UserView.NameView = class extends ViewWithTemplateSource
    MainView.UserView.NameView.FirstView = class extends ViewWithTemplateSource
    
    shared = new WingmanObject
    view = new MainView children: { options: { shared } }
    @assertEqual shared, view.get('user_view.name_view.shared')
  
  'test access to parent': ->
    MainView = class extends ViewWithTemplateSource
    MainView.UserView = class extends ViewWithTemplateSource
    MainView.UserView.NameView = class extends ViewWithTemplateSource
    
    view = new MainView
    @assert view.get('user_view.name_view').get('parent.parent') instanceof MainView
    @assert view.get('user_view.name_view.parent.parent') instanceof MainView
    
  'test ready callback': ->
    callback_fired = false
    MainView = class extends ViewWithTemplateSource
      ready: -> callback_fired = true
    
    view = new MainView
    @assert callback_fired
  
  'test build sub view': ->
    MainView = class extends ViewWithTemplateSource
    MainView.UserView = class extends ViewWithTemplateSource
    
    view = new MainView
    sub_view = view.buildSubView 'user'
    @assert sub_view instanceof MainView.UserView
    @assert view, sub_view.parent
