Janitor = require 'janitor'
Wingman = require '../../.'
View = Wingman.View
document = require('jsdom').jsdom null, null, features: { QuerySelector : true }

ViewWithTemplateSource = View.extend
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
    MainView = View.extend templateName: 'main'
    
    view = new MainView
    view.render()
    @assertEqual 1, view.el.childNodes.length
    @assertEqual 'hello', view.el.childNodes[0].innerHTML
  
  'test setting dom class': ->
    class UserView extends View
      templateSource: '<div>hello</div>'
      className: 'my-user-class'
    
    view = new UserView
    view.render()
    @assertEqual 'my-user-class', view.el.className
  
  'test simple template with dynamic values': ->
    View.templateSources['simple_with_dynamic_values'] = '<div>{myName}</div>'
    SimpleWithDynamicValuesView = View.extend
      templateName: 'simple_with_dynamic_values'
      myName: null
    
    view = new SimpleWithDynamicValuesView
    view.render()
    view.myName = 'Razda'
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
    MainView = View.extend
      templateName: 'main'
      events:
        'click .user': 'userClicked'
    
    view = new MainView
    view.render()
    clicked = false
    view.bind 'userClicked', -> clicked = true
    
    clickElement view.el.childNodes[0].childNodes[0]
    @assert clicked
    
  'test event bubbling': ->
    View.templateSources.main = '<div class="outer"><div class="user">Johnny</div></div>'
    MainView = View.extend
      templateName: 'main'
      events:
        'click .outer': 'outerClicked'
    
    view = new MainView
    view.render()
    clicked = false
    view.bind 'outerClicked', -> clicked = true
    clickElement view.el.childNodes[0].childNodes[0]
    @assert clicked
    
  'test click on views mother element': ->
    eventFromCallback = undefined
    didMaintainContext = false
    
    MainView = View.extend
      randomProperty: true
      click: (event) ->
        didMaintainContext = @randomProperty
        eventFromCallback = event
      templateSource: '<div><a>BOING</a></div>'
    
    view = new MainView
    view.render()
    
    clickElement view.el.childNodes[0].childNodes[0]
    @assert eventFromCallback
    @assertEqual 'A', eventFromCallback.target.tagName
    @assert didMaintainContext
  
  'test trigger arguments': ->
    View.templateSources.main = '<div>Something</div>'
    MainView = View.extend
      templateName: 'main'
      events:
        'click div': 'somethingHappened'
      
      somethingHappenedArguments: ->
        ['a', 'b']
    
    view = new MainView
    view.render()
    a = b = null
    view.bind 'somethingHappened', (x,y) ->
      a = x
      b = y
    
    clickElement view.el.childNodes[0]
    @assertEqual 'a', a
    @assertEqual 'b', b
  
  'test path of deeply nested view': ->
    MainView = ViewWithTemplateSource.extend
      isRoot: -> true
    
    MainView.UserView = ViewWithTemplateSource.extend()
    MainView.UserView.NameView = ViewWithTemplateSource.extend()
    MainView.UserView.NameView.FirstView = ViewWithTemplateSource.extend()
    
    main = new MainView
    user = main.createChild 'user'
    name = user.createChild 'name'
    first = name.createChild 'first'
    
    path = first.path()
    @assertEqual 3, path.length
    @assertEqual MainView.UserView, path[0]
    @assertEqual MainView.UserView.NameView, path[1]
    @assertEqual MainView.UserView.NameView.FirstView, path[2]
  
  'test state sharing': ->
    MainView = ViewWithTemplateSource.extend()
    MainView.UserView = ViewWithTemplateSource.extend()
    MainView.UserView.NameView = ViewWithTemplateSource.extend()
    
    state = new Wingman.Object()
    view = new MainView { state }
    @assertEqual state, view.createChild('user').createChild('name').state
  
  'test access to parent': ->
    MainView = ViewWithTemplateSource.extend()
    MainView.UserView = ViewWithTemplateSource.extend()
    MainView.UserView.NameView = ViewWithTemplateSource.extend()
    
    view = new MainView
    @assert view.createChild('user').createChild('name').parent.parent instanceof MainView
  
  'test ready callback': ->
    callbackFired = false
    MainView = ViewWithTemplateSource.extend
      ready: -> callbackFired = true
    
    view = new MainView
    view.render()
    @assert callbackFired
  
  'test view with child view': ->
    MainView = Wingman.View.extend templateSource: "{view 'user'}"
    MainView.UserView = ViewWithTemplateSource.extend()
    
    view = new MainView
    view.render()
    childView = view.children[0]
    @assert childView instanceof MainView.UserView
    @assert view, childView.parent
  
  'test manual creation of child view': ->
    MainView = ViewWithTemplateSource.extend()
    MainView.UserView = ViewWithTemplateSource.extend()
    
    view = new MainView
    childView = view.createChild 'user'
    @assert childView instanceof MainView.UserView
    @assert view, childView.parent
  
  'test manual creation of child view with properties': ->
    MainView = ViewWithTemplateSource.extend()
    MainView.UserView = ViewWithTemplateSource.extend()
    
    view = new MainView
    childView = view.createChild 'user', properties: { user: 'Rasmus' }
    @assertEqual 'Rasmus', childView.get('user')
  
  'test children list' :->
    MainView = ViewWithTemplateSource.extend()
    MainView.UserView = ViewWithTemplateSource.extend()
    MainView.StatusView = ViewWithTemplateSource.extend()
    
    view = new MainView
    @assertEqual 0, view.children.length
    
    userView = view.createChild 'user'
    @assertEqual 1, view.children.length
    
    statusView = view.createChild 'status'
    @assertEqual 2, view.children.length
    
    statusView.remove()
    @assertEqual 1, view.children.length
    
    userView.remove()
    @assertEqual 0, view.children.length
  
  'test manualle created child views are not rendered by default': ->
    MainView = ViewWithTemplateSource.extend()
    MainView.UserView = ViewWithTemplateSource.extend()
    
    view = new MainView
    view.render()
    childView = view.createChild 'user'
    @assert !childView.el.innerHTML
  
  'test immediate render when manually creating child view': ->
    MainView = ViewWithTemplateSource.extend()
    MainView.UserView = ViewWithTemplateSource.extend()
    
    view = new MainView
    view.render()
    childView = view.createChild 'user', render: true
    @assert childView.el.innerHTML
    
  'test manual creation of child view with two word name': ->
    MainView = ViewWithTemplateSource.extend()
    MainView.UserNameView = ViewWithTemplateSource.extend()
    
    view = new MainView
    childView = view.createChild 'userName'
    @assert childView instanceof MainView.UserNameView
    @assert view, childView.parent
  
  'test descendant view event': ->
    MainView = ViewWithTemplateSource.extend()
    MainView.UserView = ViewWithTemplateSource.extend()
    MainView.UserView.NameView = ViewWithTemplateSource.extend()
    
    main = new MainView
    callbackValues = []
    main.bind 'descendantCreated', (view) -> callbackValues.push view
    user = main.createChild 'user'
    name = user.createChild 'name'
    
    @assertEqual 2, callbackValues.length
    @assertEqual user, callbackValues[0]
    @assertEqual name, callbackValues[1]
  
  'test properties with descendant view event': ->
    MainView = ViewWithTemplateSource.extend()
    MainView.UserView = ViewWithTemplateSource.extend()
    
    main = new MainView
    callbackValue = undefined
    main.bind 'descendantCreated', (view) -> callbackValue = view.get('user')
    user = main.createChild 'user', properties: { user: 'Ras' }
    
    @assertEqual 'Ras', callbackValue
  
  'test custom tag': ->
    MainView = ViewWithTemplateSource.extend tag: 'tr'
    mainView = new MainView
    @assertEqual 'TR', mainView.el.tagName
  
  'test custom template name': ->
    View.templateSources =
      'my_custom_name': '<div>hi</div>'
    
    MainView = Wingman.View.extend
      templateName: 'my_custom_name'
    
    mainView = new MainView
    mainView.render()
    @assertEqual 'hi', mainView.el.childNodes[0].innerHTML
  
  'test template source as a string': ->
    MainView = Wingman.View.extend
      templateSource: '<div>hello</div>'
    
    mainView = new MainView
    mainView.render()
    @assertEqual 'hello', mainView.el.childNodes[0].innerHTML
  
  'test disabling template': ->
    MainView = Wingman.View.extend
      templateSource: null
    
    mainView = new MainView
    mainView.render()
    @assertEqual 0, mainView.el.childNodes.length
    
  'test appending view': ->
    MainView = Wingman.View.extend
      templateSource: null
    
    SubView = Wingman.View.extend
      templateSource: 'hello there'
    
    mainView = new MainView
    mainView.render()
    
    subView = new SubView
    subView.render()
    
    mainView.append subView
    
    @assertEqual '<div>hello there</div>', mainView.el.innerHTML
  
  'test style property': ->
    MainView = Wingman.View.extend
      templateSource: null
      left: '10px'
    
    view = new MainView
    view.render()
    @assertEqual "10px", view.el.style.left
  
  'test computed style property': ->
    MainView = Wingman.View.extend
      templateSource: null
      
      getBackgroundImage: ->
        "url('/something.jpg')"
    
    view = new MainView
    view.render()
    @assertEqual "url('/something.jpg')", view.el.style.backgroundImage
  
  'test computed style property with dependency': ->
    MainView = Wingman.View.extend
      myCode: 1
      templateSource: null
      getBackgroundImage: ->
        "url('/#{@myCode}.jpg')"
    
    MainView.addPropertyDependencies
      backgroundImage: 'myCode'
    
    view = new MainView
    view.render()
    @assertEqual "url('/1.jpg')", view.el.style.backgroundImage
    view.myCode = 2
    @assertEqual "url('/2.jpg')", view.el.style.backgroundImage
  
  'test child views object': ->
    MainView = Wingman.View.extend
      templateSource: null
    
    MyViews = {}
    MyViews.NameView = Wingman.View.extend
      templateSource: null
    
    view = new MainView childClasses: MyViews
    nameView = view.createChild 'name'
    @assert nameView instanceof MyViews.NameView
  
  'test computed properties depending on app property not being called upon initialization': ->
    called = false
    NameView = Wingman.View.extend
      templateSource: null
      something: -> called = true
    
    NameView.addPropertyDependencies
      something: 'app.loggedIn'
    
    view = new NameView app: new Wingman.Object()
    @assert !called
  
  'test sub context and descendantCreated event': ->
    view = new Wingman.View()
    subContext = view.createSubContext()
    callbackFired = true
    view.bind 'descendantCreated', -> callbackFired = true
    subContext.trigger 'descendantCreated'
    @assert callbackFired
