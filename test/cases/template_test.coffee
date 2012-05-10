Janitor = require 'janitor'
Wingman = require '../..'
jsdom = require 'jsdom'
CustomAssertions = require '../custom_assertions'

module.exports = class TemplateTest extends Janitor.TestCase
  setup: ->
    Wingman.document = jsdom.jsdom()
    @parent = Wingman.document.createElement 'div'
  
  teardown: ->
    delete Wingman.document
  
  assertElementHasClass: CustomAssertions.assertDOMElementHasClass
  refuteElementHasClass: CustomAssertions.refuteDOMElementHasClass
  
  'test template with only static text': ->
    template = Wingman.Template.compile 'hello'
    template @parent
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'hello', @parent.innerHTML
  
  'test simple template with tag containing static value': ->
    template = Wingman.Template.compile '<div>hello</div>'
    template @parent
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'hello', @parent.childNodes[0].innerHTML
  
  'test template with nested tags': ->
    template = Wingman.Template.compile '<ol><li>hello</li></ol>'
    template @parent
    
    @assertEqual 1, @parent.childNodes.length
    olElm = @parent.childNodes[0]
    @assertEqual 1, olElm.childNodes.length
    @assertEqual 'hello', olElm.childNodes[0].innerHTML
  
  'test template with only dynamic value': ->
    template = Wingman.Template.compile '{greeting}'
    context = setupContext greeting: 'hello'
    template @parent, context
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'hello', @parent.innerHTML
  
  'test deferred context update with template with only dynamic value': ->
    template = Wingman.Template.compile '{greeting}'
    context = setupContext greeting: 'hello'
    template @parent, context
    context.set greeting: 'good morning'
    @assertEqual 'good morning', @parent.innerHTML
  
  'test basic template with dynamic content': ->
    template = Wingman.Template.compile '<div>{greeting}</div>'
    context = setupContext greeting: 'hello'
    template @parent, context
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'hello', @parent.childNodes[0].innerHTML
  
  'test template with dynamic value after updating context': ->
    template = Wingman.Template.compile '<div>{greeting}</div>'
    context = setupContext greeting: 'hello'
    template @parent, context
    context.set greeting: 'hi'
  
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'hi', @parent.childNodes[0].innerHTML
  
  'test template with nested dynamic value after updating context': ->
    template = Wingman.Template.compile '<div>{user.name}</div>'
    user = setupContext name: 'Rasmus'
    context = setupContext { user }
    template @parent, context
    
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'Rasmus', @parent.childNodes[0].innerHTML
    
    user.set name: 'John'
    @assertEqual 'John', @parent.childNodes[0].innerHTML
  
  'test for token': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'
    
    context = setupContext users: ['Rasmus', 'John']
    template @parent, context
    
    @assertEqual 1, @parent.childNodes.length
    
    olElm = @parent.childNodes[0]
    @assertEqual 2, olElm.childNodes.length
    @assertEqual 'Rasmus', olElm.childNodes[0].innerHTML
    @assertEqual 'John', olElm.childNodes[1].innerHTML
  
  'test for token with deferred push': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'
  
    context = setupContext users: ['Rasmus', 'John']
    template @parent, context
  
    olElm = @parent.childNodes[0]
    @assertEqual 2, olElm.childNodes.length
  
    context.users.push 'Oliver'
    @assertEqual 3, olElm.childNodes.length
    @assertEqual 'Oliver', olElm.childNodes[2].innerHTML
  
  'test for token with deferred remove': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'
  
    context = setupContext users: ['Rasmus', 'John']
    template @parent, context
  
    olElm = @parent.childNodes[0]
    @assertEqual 2, olElm.childNodes.length
  
    context.users.remove 'John'
    @assertEqual 1, olElm.childNodes.length
  
  'test for token with deferred reset': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'
  
    context = setupContext users: ['Rasmus', 'John']
    template @parent, context
    olElm = @parent.childNodes[0]
    context.users = ['Oliver']
    @assertEqual 1, olElm.childNodes.length
    @assertEqual 'Oliver', olElm.childNodes[0].innerHTML
  
  'test element with single static style': ->
    template = Wingman.Template.compile '<div style="color:red">yo</div>'
    template @parent
  
    @assertEqual 'red', @parent.childNodes[0].style.color
  
  'test element with single dynamic style': ->
    template = Wingman.Template.compile '<div style="color:{color}">yo</div>'
    context = setupContext color: 'red'
    elements = template @parent, context
    
    @assertEqual 'red', @parent.childNodes[0].style.color
  
  'test deferred reset for element with single dynamic style': ->
    template = Wingman.Template.compile '<div style="color:{myColor}">yo</div>'
    context = setupContext myColor: 'red'
    template @parent, context
    context.myColor = 'blue'
    @assertEqual 'blue', @parent.childNodes[0].style.color
  
  'test element with two static styles': ->
    template = Wingman.Template.compile '<div style="color:{myColor}; font-size: 15px">yo</div>'
    context = setupContext myColor: 'red'
    template @parent, context
    
    @assertEqual 'red', @parent.childNodes[0].style.color
    @assertEqual '15px', @parent.childNodes[0].style.fontSize
  
  'test element with two dynamic styles': ->
    template = Wingman.Template.compile '<div style="color:{myColor}; font-size: {myFontSize}">yo</div>'
    context = setupContext myColor: 'red', myFontSize: '15px'
    template @parent, context
    
    @assertEqual 'red', @parent.childNodes[0].style.color
    @assertEqual '15px', @parent.childNodes[0].style.fontSize
    
    context.set myColor: 'blue', myFontSize: '13px'
    @assertEqual 'blue', @parent.childNodes[0].style.color
    @assertEqual '13px', @parent.childNodes[0].style.fontSize
  
  'test element with single static class': ->
    template = Wingman.Template.compile '<div class="user">something</div>'
    template @parent
    @assertEqual @parent.childNodes[0].className, 'user'
  
  'test element with several static classes': ->
    template = Wingman.Template.compile '<div class="premium user">something</div>'
    template @parent
    element = @parent.childNodes[0]
    @assertElementHasClass element, 'user'
    @assertElementHasClass element, 'premium'
  
  'test element with single dynamic class': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass}">something</div>'
    context = setupContext myAwesomeClass: 'user'
    
    template @parent, context
    @assertElementHasClass @parent.childNodes[0], 'user'
  
  'test deferred reset with element with single dynamic class': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass}">something</div>'
    context = setupContext myAwesomeClass: 'user'
  
    template @parent, context
    element = @parent.childNodes[0]
    @assertEqual element.className, 'user'
  
    context.myAwesomeClass = 'something_else'
    @assertEqual element.className, 'something_else'
  
  'test deferred reset to falsy value with element with single dynamic class': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass}">something</div>'
    context = setupContext myAwesomeClass: 'user'
    
    template @parent, context
    element = @parent.childNodes[0]
    @assertEqual element.className, 'user'
  
    context.myAwesomeClass = null
    @assertEqual element.className, ''
  
  'test element with two dynamic classes that evaluates to the same value': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass} {mySuperbClass}">something</div>'
    context = setupContext myAwesomeClass: 'user', mySuperbClass: 'user'
  
    template @parent, context
    @assertEqual @parent.childNodes[0].className, 'user'
  
  'test deferred reset of dynamic class that evaluates to the same value as another dynamic class': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass} {mySuperbClass}">something</div>'
    context = setupContext myAwesomeClass: 'user', mySuperbClass: 'user'
    
    template @parent, context
    element = @parent.childNodes[0]
    
    context.mySuperbClass = 'premium'
    @assertElementHasClass element, 'user'
    @assertElementHasClass element, 'premium'
  
  'test element with dynamic and static class': ->
    template = Wingman.Template.compile '<div class="user {selectedCls}">something</div>'
    context = setupContext selectedCls: 'selected'
    
    template @parent, context
    element = @parent.childNodes[0]
    @assertElementHasClass element, 'user'
    @assertElementHasClass element, 'selected'
  
  'test deactivated dynamic class when also having static class': ->
    template = Wingman.Template.compile '<div class="user {selectedCls}">something</div>'
    context = setupContext selectedCls: undefined
    
    template @parent, context
    element = @parent.childNodes[0]
    @assertEqual 'user', element.className
  
  'test deferred deactivation of dynamic class when also having static class': ->
    template = Wingman.Template.compile '<div class="user {selectedCls}">something</div>'
    context = setupContext selectedCls: 'selected'
    
    template @parent, context
    element = @parent.childNodes[0]
    
    context.set selectedCls: undefined
    @assertEqual 'user', element.className
  
  'test child view': ->
    template = Wingman.Template.compile "<div>Test</div>{view 'user'}"
    
    MainView = Wingman.View.extend
      templateSource: '<div>tester</div>'
    
    MainView.UserView = Wingman.View.extend
      templateSource: '<div>tester</div>'
    
    context = new MainView
    template @parent, context
    
    @assertEqual 2, @parent.childNodes.length
    @assertEqual '<div>tester</div>', @parent.childNodes[1].innerHTML
  
  'test regular attributes': ->
    template = Wingman.Template.compile '<img src="my_pic.jpg">'
    template @parent
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'my_pic.jpg', @parent.childNodes[0].getAttribute('src')
  
  'test regular attributes with dynamic values': ->
    template = Wingman.Template.compile '<img src="{mySrc}">'
    context = setupContext mySrc: 'my_pic.png'
    
    template @parent, context
    
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'my_pic.png', @parent.childNodes[0].getAttribute('src')
    context.mySrc = 'my_pic2.png'
    @assertEqual 'my_pic2.png', @parent.childNodes[0].getAttribute('src')
  
  'test for block containing sub view': ->
    MainView = Wingman.View.extend
      users: null
      templateSource: "<section>{for users}{view 'user'}{end}</section>"
    
    MainView.UserView = Wingman.View.extend
      templateSource: '<div>{user}</div>'
    
    mainView = new MainView
    template = Wingman.Template.compile mainView.get('templateSource')
    template @parent, mainView
    mainView.users = ['Rasmus', 'John']
    
    @assertEqual 2, @parent.childNodes[0].childNodes.length
    @assertEqual 'Rasmus', @parent.childNodes[0].childNodes[0].childNodes[0].innerHTML
    @assertEqual 'John', @parent.childNodes[0].childNodes[1].childNodes[0].innerHTML
  
  'test simple conditional': ->
    context = setupContext something: false
    template = Wingman.Template.compile '{if something}<div>hello</div>{end}'
    template @parent, context
    
    childNodes = @parent.childNodes
    @assertEqual 0, childNodes.length
    context.something = true
    @assertEqual 1, childNodes.length
    @assertEqual 'hello', childNodes[0].innerHTML
    
  'test if else conditional': ->
    context = setupContext early: false
    template = Wingman.Template.compile '{if early}<div>good morning</div>{else}<div>good evening</div>{end}'
    template @parent, context
    
    childNodes = @parent.childNodes
    @assertEqual 1, childNodes.length
    @assertEqual 'good evening', childNodes[0].innerHTML
    context.early = true
    @assertEqual 1, childNodes.length
    @assertEqual 'good morning', childNodes[0].innerHTML
  
  'test element surrounded by text': ->
    context = setupContext()
    template = Wingman.Template.compile 'Hello <span>Rasmus</span>, how are you?'
    template @parent, context
    
    @assertEqual 'Hello <span>Rasmus</span>, how are you?', @parent.innerHTML
  
  'test element with source surrounded by text': ->
    context = setupContext name: 'Rasmus'
    
    template = Wingman.Template.compile 'Hello <span>{name}</span>, how are you?'
    template @parent, context
    
    @assertEqual 'Hello <span>Rasmus</span>, how are you?', @parent.innerHTML
  
  'test deferred context update with source element surrounded by text': ->
    context = setupContext name: 'Rasmus'
    
    template = Wingman.Template.compile 'Hello <span>{name}</span>, how are you?'
    template @parent, context
    
    context.name = 'Monkey Joe'
    
    @assertEqual 'Hello <span>Monkey Joe</span>, how are you?', @parent.innerHTML

setupContext = (hash) ->
  properties = {}
  properties[key] = null for key, value of hash

  Context = Wingman.Object.extend properties
  context = new Context
  context[key] = value for key, value of hash
  context
