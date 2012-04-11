Janitor = require 'janitor'
Wingman = require '../..'
WingmanObject = require '../../lib/wingman/shared/object'
document = require('jsdom').jsdom()
CustomAssertions = require '../custom_assertions'
Wingman.document = document

module.exports = class TemplateTest extends Janitor.TestCase
  setup: ->
    @parent = Wingman.document.createElement 'div'
  
  assertElementHasClass: CustomAssertions.assertDOMElementHasClass
  refuteElementHasClass: CustomAssertions.refuteDOMElementHasClass
  
  'test basic template with static value': ->
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
  
  'test basic template with dynamic content': ->
    template = Wingman.Template.compile '<div>{greeting}</div>'
    context = new WingmanObject
    context.set greeting: 'hello'
    template @parent, context
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'hello', @parent.childNodes[0].innerHTML
  
  'test template with dynamic value after updating context': ->
    template = Wingman.Template.compile '<div>{greeting}</div>'
    context = new WingmanObject
    context.set greeting: 'hello'
    template @parent, context
    context.set greeting: 'hi'
  
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'hi', @parent.childNodes[0].innerHTML
  
  'test template with nested dynamic value after updating context': ->
    template = Wingman.Template.compile '<div>{user.name}</div>'
    user = new WingmanObject
    user.set name: 'Rasmus'
    context = new WingmanObject
    context.set {user}
    template @parent, context
    
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'Rasmus', @parent.childNodes[0].innerHTML
    
    user.set name: 'John'
    @assertEqual 'John', @parent.childNodes[0].innerHTML
  
  'test for token': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'
  
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
    template @parent, context
  
    @assertEqual 1, @parent.childNodes.length
  
    olElm = @parent.childNodes[0]
    @assertEqual 2, olElm.childNodes.length
    @assertEqual 'Rasmus', olElm.childNodes[0].innerHTML
    @assertEqual 'John', olElm.childNodes[1].innerHTML
  
  'test for token with deferred push': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'
  
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
    template @parent, context
  
    olElm = @parent.childNodes[0]
    @assertEqual 2, olElm.childNodes.length
  
    context.get('users').push 'Oliver'
    @assertEqual 3, olElm.childNodes.length
    @assertEqual 'Oliver', olElm.childNodes[2].innerHTML
  
  'test for token with deferred remove': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'
  
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
    template @parent, context
  
    olElm = @parent.childNodes[0]
    @assertEqual 2, olElm.childNodes.length
  
    context.get('users').remove 'John'
    @assertEqual 1, olElm.childNodes.length
  
  'test for token with deferred reset': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'
  
    context = new WingmanObject
    context.set users: ['Rasmus', 'John']
    template @parent, context
    olElm = @parent.childNodes[0]
    context.set users: ['Oliver']
    @assertEqual 1, olElm.childNodes.length
    @assertEqual 'Oliver', olElm.childNodes[0].innerHTML
  
  'test element with single static style': ->
    template = Wingman.Template.compile '<div style="color:red">yo</div>'
    template @parent
  
    @assertEqual 'red', @parent.childNodes[0].style.color
  
  'test element with single dynamic style': ->
    template = Wingman.Template.compile '<div style="color:{color}">yo</div>'
    context = new WingmanObject
    context.set color: 'red'
    elements = template @parent, context
  
    @assertEqual 'red', @parent.childNodes[0].style.color
  
  'test deferred reset for element with single dynamic style': ->
    template = Wingman.Template.compile '<div style="color:{myColor}">yo</div>'
    context = new WingmanObject
    context.set myColor: 'red'
    template @parent, context
    context.set myColor: 'blue'
    @assertEqual 'blue', @parent.childNodes[0].style.color
  
  'test element with two static styles': ->
    template = Wingman.Template.compile '<div style="color:{myColor}; font-size: 15px">yo</div>'
    context = new WingmanObject
    context.set myColor: 'red'
    template @parent, context
  
    @assertEqual 'red', @parent.childNodes[0].style.color
    @assertEqual '15px', @parent.childNodes[0].style.fontSize
  
  'test element with two dynamic styles': ->
    template = Wingman.Template.compile '<div style="color:{myColor}; font-size: {myFontSize}">yo</div>'
    context = new WingmanObject
    context.set myColor: 'red', myFontSize: '15px'
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
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    template @parent, context
    @assertElementHasClass @parent.childNodes[0], 'user'
  
  'test deferred reset with element with single dynamic class': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass}">something</div>'
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
  
    template @parent, context
    element = @parent.childNodes[0]
    @assertEqual element.className, 'user'
  
    context.set myAwesomeClass: 'something_else'
    @assertEqual element.className, 'something_else'
  
  'test deferred reset to falsy value with element with single dynamic class': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass}">something</div>'
    context = new WingmanObject
    context.set myAwesomeClass: 'user'
    
    template @parent, context
    element = @parent.childNodes[0]
    @assertEqual element.className, 'user'
  
    context.set myAwesomeClass: null
    @assertEqual element.className, ''
  
  'test element with two dynamic classes that evaluates to the same value': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass} {mySuperbClass}">something</div>'
    context = new WingmanObject
    context.set myAwesomeClass: 'user', mySuperbClass: 'user'
  
    template @parent, context
    @assertEqual @parent.childNodes[0].className, 'user'
  
  'test deferred reset of dynamic class that evaluates to the same value as another dynamic class': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass} {mySuperbClass}">something</div>'
    context = new WingmanObject
    context.set myAwesomeClass: 'user', mySuperbClass: 'user'
    
    template @parent, context
    element = @parent.childNodes[0]
    
    context.set mySuperbClass: 'premium'
    @assertElementHasClass element, 'user'
    @assertElementHasClass element, 'premium'
  
  'test child view': ->
    template = Wingman.Template.compile '<div>Test</div>{view user}'
    
    class MainView extends Wingman.View
      templateSource: -> '<div>tester</div>'
    
    class MainView.UserView extends Wingman.View
      templateSource: -> '<div>tester</div>'
    
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
    context = new WingmanObject
    context.set mySrc: 'my_pic.png'
    
    template @parent, context
    
    @assertEqual 1, @parent.childNodes.length
    @assertEqual 'my_pic.png', @parent.childNodes[0].getAttribute('src')
    context.set mySrc: 'my_pic2.png'
    @assertEqual 'my_pic2.png', @parent.childNodes[0].getAttribute('src')
  
  'test for block containing sub view': ->
    class MainView extends Wingman.View
      templateSource: -> '<section>{for users}{view user}{end}</section>'
    
    class MainView.UserView extends Wingman.View
      templateSource: -> '<div>{user}</div>'
    
    mainView = new MainView
    template = Wingman.Template.compile mainView.templateSource()
    template @parent, mainView
    mainView.set users: ['Rasmus', 'John']
    
    @assertEqual 2, @parent.childNodes[0].childNodes.length
    @assertEqual 'Rasmus', @parent.childNodes[0].childNodes[0].childNodes[0].innerHTML
    @assertEqual 'John', @parent.childNodes[0].childNodes[1].childNodes[0].innerHTML
  
  'test simple conditional': ->
    context = new WingmanObject
    template = Wingman.Template.compile '{if something}<div>hello</div>{end}'
    template @parent, context
    
    childNodes = @parent.childNodes
    @assertEqual 0, childNodes.length
    context.set something: true
    @assertEqual 1, childNodes.length
    @assertEqual 'hello', childNodes[0].innerHTML
    
  'test if else conditional': ->
    context = new WingmanObject
    template = Wingman.Template.compile '{if early}<div>good morning</div>{else}<div>good evening</div>{end}'
    template @parent, context
    
    childNodes = @parent.childNodes
    @assertEqual 1, childNodes.length
    @assertEqual 'good evening', childNodes[0].innerHTML
    context.set early: true
    @assertEqual 1, childNodes.length
    @assertEqual 'good morning', childNodes[0].innerHTML
