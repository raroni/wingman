Janitor = require 'janitor'
Wingman = require '../../.'
WingmanObject = require '../../lib/wingman/shared/object'
View = Wingman.View
document = require('jsdom').jsdom(null, null, features: {
        QuerySelector : true
      })

ViewWithTemplateSource = class extends View
  templateSource: '<div>test</div>'

clickElement = (elm) ->
  event = document.createEvent "MouseEvents"
  event.initMouseEvent "click", true, true
  elm.dispatchEvent event

module.exports = class ViewTest extends Janitor.TestCase
  setup: ->
    Wingman.document = document
    View.templateSources = {}
  
  teardown: ->
    delete View.templateSources
  
  'test simple template': ->
    View.templateSources.main = '<div>hello</div>'
    class MainView extends View
    
    dummyApp =
      pathKeys: -> []
      el: document.createElement('div')
    
    view = new MainView parent: dummyApp, render: true
    @assertEqual 1, view.el.childNodes.length
    @assertEqual 'hello', view.el.childNodes[0].innerHTML
    
  'test setting dom class': ->
    class UserView extends View
      templateSource: '<div>hello</div>'
  
    view = new UserView render: true
    @assertEqual 'user', view.el.className
  
  'test simple template with dynamic values': ->
    View.templateSources['simple_with_dynamic_values'] = '<div>{myName}</div>'
    class SimpleWithDynamicValuesView extends View
    
    dummyApp =
      pathKeys: -> []
      el: document.createElement('div')
    
    view = new SimpleWithDynamicValuesView parent: dummyApp, render: true
    view.set myName: 'Razda'
    @assertEqual 1, view.el.childNodes.length
    @assertEqual 'Razda', view.el.childNodes[0].innerHTML
  
  'test parse events': ->
    eventsHash =
      'click .user': 'userClicked'
      'hover button.some_class': 'buttonHovered'
      
    events = View.parseEvents(eventsHash).sort (e1, e2) -> e1.type > e2.type
    
    @assertEqual 'click', events[0].type
    @assertEqual 'userClicked', events[0].trigger
    @assertEqual '.user', events[0].selector
    
    @assertEqual 'hover', events[1].type
    @assertEqual 'buttonHovered', events[1].trigger
    @assertEqual 'button.some_class', events[1].selector
  
  'test simple event': ->
    View.templateSources.main = '<div><div class="user">Johnny</div></div>'
    class MainView extends View
      @_name: 'test'
      events:
        'click .user': 'userClicked'
    
    dummyApp =
      pathKeys: -> []
      el: document.createElement('div')
    
    view = new MainView parent: dummyApp, render: true
    clicked = false
    view.bind 'userClicked', ->
      clicked = true
    
    clickElement view.el.childNodes[0].childNodes[0]
    @assert clicked
    
  'test event bubbling': ->
    View.templateSources.main = '<div class="outer"><div class="user">Johnny</div></div>'
    class MainView extends View
      @_name: 'test'
      events:
        'click .outer': 'outerClicked'
    
    view = new MainView render: true
    clicked = false
    view.bind 'outerClicked', -> clicked = true
    clickElement view.el.childNodes[0].childNodes[0]
    @assert clicked
    
  'test click on views mother element': ->
    eventFromCallback = undefined
    didMaintainContext = false
    class MainView extends View
      randomProperty: true
      click: (event) ->
        didMaintainContext = @randomProperty
        eventFromCallback = event
      templateSource: '<div><a>BOING</a></div>'
    
    view = new MainView render: true
    clickElement view.el.childNodes[0].childNodes[0]
    @assert eventFromCallback
    @assertEqual 'A', eventFromCallback.target.tagName
    @assert didMaintainContext
  
  'test trigger arguments': ->
    View.templateSources.main = '<div>Something</div>'
    class MainView extends View
      @_name: 'test'
      events:
        'click div': 'somethingHappened'
      
      somethingHappenedArguments: ->
        ['a', 'b']
    
    dummyApp =
      pathKeys: -> []
      el: document.createElement('div')
    
    view = new MainView parent: dummyApp, render: true
    a = null
    b = null
    view.bind 'somethingHappened', (x,y) ->
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
    user = main.createChild 'user'
    name = user.createChild 'name'
    first = name.createChild 'first'
    @assertEqual 'user.name.first', first.path()
  
  'test app instance sharing': ->
    class MainView extends ViewWithTemplateSource
    class MainView.UserView extends ViewWithTemplateSource
    class MainView.UserView.NameView extends ViewWithTemplateSource
    
    app = new WingmanObject
    view = new MainView { app, render: true }
    @assertEqual app, view.createChild('user').createChild('name').get('app')
  
  'test access to parent': ->
    class MainView extends ViewWithTemplateSource
    class MainView.UserView extends ViewWithTemplateSource
    class MainView.UserView.NameView extends ViewWithTemplateSource
    
    view = new MainView render: true
    @assert view.createChild('user').createChild('name').get('parent.parent') instanceof MainView
    
  'test ready callback': ->
    callbackFired = false
    class MainView extends ViewWithTemplateSource
      ready: -> callbackFired = true
    
    view = new MainView render: true
    @assert callbackFired
  
  'test single word name': ->
    class MainView extends ViewWithTemplateSource
    view = new MainView
    @assertEqual 'main', view.get('name')
  
  'test double word name': ->
    class UserNameView extends ViewWithTemplateSource
    view = new UserNameView
    @assertEqual 'userName', view.get('name')
  
  'test view with child view': ->
    class MainView extends Wingman.View
      templateSource: "{view 'user'}"
    
    class MainView.UserView extends ViewWithTemplateSource
    
    view = new MainView render: true
    childView = view.get('children')[0]
    @assert childView instanceof MainView.UserView
    @assert view, childView.parent
  
  'test manual creation of child view': ->
    class MainView extends ViewWithTemplateSource
    class MainView.UserView extends ViewWithTemplateSource
    
    view = new MainView
    childView = view.createChild 'user'
    @assert childView instanceof MainView.UserView
    @assert view, childView.parent
  
  'test manual creation of child view with properties': ->
    class MainView extends ViewWithTemplateSource
    class MainView.UserView extends ViewWithTemplateSource
    
    view = new MainView
    childView = view.createChild 'user', properties: { user: 'Rasmus' }
    @assertEqual 'Rasmus', childView.get('user')
  
  'test children list' :->
    class MainView extends ViewWithTemplateSource
    class MainView.UserView extends ViewWithTemplateSource
    class MainView.StatusView extends ViewWithTemplateSource
    
    view = new MainView
    @assertEqual 0, view.get('children').length
    
    userView = view.createChild 'user'
    @assertEqual 1, view.get('children').length
    
    statusView = view.createChild 'status'
    @assertEqual 2, view.get('children').length
    
    statusView.remove()
    @assertEqual 1, view.get('children').length
    
    userView.remove()
    @assertEqual 0, view.get('children').length
  
  'test manualle created child views are not rendered by default': ->
    class MainView extends ViewWithTemplateSource
    class MainView.UserView extends ViewWithTemplateSource
    
    view = new MainView render: true
    childView = view.createChild 'user'
    @assert !childView.el.innerHTML
  
  'test immediate render when manually creating child view': ->
    class MainView extends ViewWithTemplateSource
    class MainView.UserView extends ViewWithTemplateSource
    
    view = new MainView render: true
    childView = view.createChild 'user', render: true
    @assert childView.el.innerHTML
    
  'test manual creation of child view with two word name': ->
    class MainView extends ViewWithTemplateSource
    class MainView.UserNameView extends ViewWithTemplateSource
    
    view = new MainView render: true
    childView = view.createChild 'userName'
    @assert childView instanceof MainView.UserNameView
    @assert view, childView.parent
  
  'test descendant view event': ->
    class MainView extends ViewWithTemplateSource
    class MainView.UserView extends ViewWithTemplateSource
    class MainView.UserView.NameView extends ViewWithTemplateSource
    
    main = new MainView
    callbackValues = []
    main.bind 'descendantCreated', (view) -> callbackValues.push view
    user = main.createChild 'user'
    name = user.createChild 'name'
    
    @assertEqual 2, callbackValues.length
    @assertEqual user, callbackValues[0]
    @assertEqual name, callbackValues[1]
  
  'test properties with descendant view event': ->
    class MainView extends ViewWithTemplateSource
    class MainView.UserView extends ViewWithTemplateSource
    
    main = new MainView
    callbackValue = undefined
    main.bind 'descendantCreated', (view) -> callbackValue = view.get('user')
    user = main.createChild 'user', properties: { user: 'Ras' }
    
    @assertEqual 'Ras', callbackValue
  
  'test custom tag': ->
    class MainView extends ViewWithTemplateSource
      tag: 'tr'
    
    mainView = new MainView render: true
    @assertEqual 'TR', mainView.el.tagName
  
  'test custom template name': ->
    View.templateSources =
      'my_custom_name': '<div>hi</div>'
    
    class MainView extends Wingman.View
      templateName: 'my_custom_name'
    
    mainView = new MainView render: true
    @assertEqual 'hi', mainView.el.childNodes[0].innerHTML
  
  'test template source as a string': ->
    class MainView extends Wingman.View
      templateSource: '<div>hello</div>'
    
    mainView = new MainView render: true
    @assertEqual 'hello', mainView.el.childNodes[0].innerHTML
  
  'test disabling template': ->
    class MainView extends Wingman.View
      templateSource: null
    
    mainView = new MainView render: true
    @assertEqual 0, mainView.el.childNodes.length
    
  'test appending view': ->
    class MainView extends Wingman.View
      templateSource: null
      
    class SubView extends Wingman.View
      templateSource: '<div>hello</div>'
    
    mainView = new MainView render: true
    subView = new SubView render: true
    mainView.append subView
    
    @assertEqual '<div class="sub"><div>hello</div></div>', mainView.el.innerHTML
  
  'test style property': ->
    class MainView extends Wingman.View
      templateSource: null
      left: '10px'
    
    view = new MainView render: true
    @assertEqual "10px", view.el.style.left
  
  'test computed style property': ->
    class MainView extends Wingman.View
      templateSource: null
      
      backgroundImage: ->
        "url('/something.jpg')"
    
    view = new MainView render: true
    @assertEqual "url('/something.jpg')", view.el.style.backgroundImage
  
  'test computed style property with dependency': ->
    class MainView extends Wingman.View
      myCode: 1
      templateSource: null
      @propertyDependencies
        backgroundImage: 'myCode'
      
      backgroundImage: ->
        "url('/#{@get('myCode')}.jpg')"
    
    view = new MainView render: true
    @assertEqual "url('/1.jpg')", view.el.style.backgroundImage
    view.set myCode: 2
    @assertEqual "url('/2.jpg')", view.el.style.backgroundImage
  
  'test child views object': ->
    class MainView extends Wingman.View
      templateSource: null
    
    MyViews = {}
    class MyViews.NameView extends Wingman.View
      templateSource: null
    
    view = new MainView childClasses: MyViews
    view.createChild 'name'
  
  'test computed properties depending on app property not being called upon initialization': ->
    called = false
    class NameView extends Wingman.View
      templateSource: null
      @propertyDependencies
        something: 'app.loggedIn'
      
      something: -> called = true
    
    view = new NameView app: {}
    @assert !called
  
  'test sub context and descendantCreated event': ->
    view = new Wingman.View
    subContext = view.createSubContext()
    callbackFired = true
    view.bind 'descendantCreated', -> callbackFired = true
    subContext.trigger 'descendantCreated'
    @assert callbackFired
