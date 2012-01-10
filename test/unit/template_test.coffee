Janitor = require 'janitor'
Wingman = require '../..'
document = require('jsdom').jsdom()
CustomAssertions = require '../custom_assertions'

module.exports = class extends Janitor.TestCase
  setup: ->
    Wingman.document = document
  
  assertElementHasClass: CustomAssertions.assertDOMElementHasClass
  refuteElementHasClass: CustomAssertions.refuteDOMElementHasClass
  
  'test basic template with static value': ->
    template = Wingman.Template.compile '<div>hello</div>'
    elements = template()
    @assertEqual 1, elements.length
    @assertEqual 'hello', elements[0].innerHTML

  'test template with nested tags': ->
    template = Wingman.Template.compile '<ol><li>hello</li></ol>'
    elements = template()

    @assertEqual 1, elements.length
    ol_elm = elements[0]
    @assertEqual 1, ol_elm.childNodes.length
    @assertEqual 'hello', ol_elm.childNodes[0].innerHTML

  'test basic template with dynamic content': ->
    template = Wingman.Template.compile '<div>{greeting}</div>'
    context = new Wingman.Object
    context.set greeting: 'hello'
    elements = template context
    @assertEqual 1, elements.length
    @assertEqual 'hello', elements[0].innerHTML

  'test template with dynamic value after updating context': ->
    template = Wingman.Template.compile '<div>{greeting}</div>'
    context = new Wingman.Object
    context.set greeting: 'hello'
    elements = template context
    context.set greeting: 'hi'

    @assertEqual 1, elements.length
    @assertEqual 'hi', elements[0].innerHTML

  'test template with nested dynamic value after updating context': ->
    template = Wingman.Template.compile '<div>{user.name}</div>'
    user = new Wingman.Object
    user.set name: 'Rasmus'
    context = new Wingman.Object
    context.set {user}
    elements = template context
    
    @assertEqual 1, elements.length
    @assertEqual 'Rasmus', elements[0].innerHTML
    
    user.set name: 'John'
    @assertEqual 'John', elements[0].innerHTML

  'test for token': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'

    context = new Wingman.Object
    context.set users: ['Rasmus', 'John']
    elements = template context

    @assertEqual 1, elements.length

    ol_elm = elements[0]
    @assertEqual 2, ol_elm.childNodes.length
    @assertEqual 'Rasmus', ol_elm.childNodes[0].innerHTML
    @assertEqual 'John', ol_elm.childNodes[1].innerHTML

  'test for token with deferred push': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'

    context = new Wingman.Object
    context.set users: ['Rasmus', 'John']
    elements = template context

    ol_elm = elements[0]
    @assertEqual 2, ol_elm.childNodes.length

    context.get('users').push 'Oliver'
    @assertEqual 3, ol_elm.childNodes.length
    @assertEqual 'Oliver', ol_elm.childNodes[2].innerHTML

  'test for token with deferred remove': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'

    context = new Wingman.Object
    context.set users: ['Rasmus', 'John']
    elements = template context

    ol_elm = elements[0]
    @assertEqual 2, ol_elm.childNodes.length

    context.get('users').remove 'John'
    @assertEqual 1, ol_elm.childNodes.length

  'test for token with deferred reset': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'

    context = new Wingman.Object
    context.set users: ['Rasmus', 'John']
    elements = template context
    ol_elm = elements[0]
    context.set users: ['Oliver']
    @assertEqual 1, ol_elm.childNodes.length
    @assertEqual 'Oliver', ol_elm.childNodes[0].innerHTML
  
  'test element with single static style': ->
    template = Wingman.Template.compile '<div style="color:red">yo</div>'
    elements = template()

    @assertEqual 'red', elements[0].style.color

  'test element with single dynamic style': ->
    template = Wingman.Template.compile '<div style="color:{color}">yo</div>'
    context = new Wingman.Object
    context.set color: 'red'
    elements = template context

    @assertEqual 'red', elements[0].style.color

  'test deferred reset for element with single dynamic style': ->
    template = Wingman.Template.compile '<div style="color:{myColor}">yo</div>'
    context = new Wingman.Object
    context.set myColor: 'red'
    elements = template context
    context.set myColor: 'blue'
    @assertEqual 'blue', elements[0].style.color

  'test element with two static styles': ->
    template = Wingman.Template.compile '<div style="color:{myColor}; font-size: 15px">yo</div>'
    context = new Wingman.Object
    context.set myColor: 'red'
    elements = template context

    @assertEqual 'red', elements[0].style.color
    @assertEqual '15px', elements[0].style.fontSize
  
  'test element with two dynamic styles': ->
    template = Wingman.Template.compile '<div style="color:{myColor}; font-size: {myFontSize}">yo</div>'
    context = new Wingman.Object
    context.set myColor: 'red', myFontSize: '15px'
    elements = template context

    @assertEqual 'red', elements[0].style.color
    @assertEqual '15px', elements[0].style.fontSize

    context.set myColor: 'blue', myFontSize: '13px'
    @assertEqual 'blue', elements[0].style.color
    @assertEqual '13px', elements[0].style.fontSize

  'test element with single static class': ->
    template = Wingman.Template.compile '<div class="user">something</div>'
    element = template()[0]
    @assertEqual element.className, 'user'

  'test element with several static classes': ->
    template = Wingman.Template.compile '<div class="premium user">something</div>'
    element = template()[0]
    @assertElementHasClass element, 'user'
    @assertElementHasClass element, 'premium'
  
  'test element with single dynamic class': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass}">something</div>'
    context = new Wingman.Object
    context.set myAwesomeClass: 'user'

    element = template(context)[0]
    @assertElementHasClass element, 'user'

  'test deferred reset with element with single dynamic class': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass}">something</div>'
    context = new Wingman.Object
    context.set myAwesomeClass: 'user'

    element = template(context)[0]
    @assertEqual element.className, 'user'

    context.set myAwesomeClass: 'something_else'
    @assertEqual element.className, 'something_else'

  'test deferred reset to falsy value with element with single dynamic class': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass}">something</div>'
    context = new Wingman.Object
    context.set myAwesomeClass: 'user'

    element = template(context)[0]
    @assertEqual element.className, 'user'

    context.set myAwesomeClass: null
    @assertEqual element.className, ''

  'test element with two dynamic classes that evaluates to the same value': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass} {mySuperbClass}">something</div>'
    context = new Wingman.Object
    context.set myAwesomeClass: 'user', mySuperbClass: 'user'

    element = template(context)[0]
    @assertEqual element.className, 'user'

  'test deferred reset of dynamic class that evaluates to the same value as another dynamic class': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass} {mySuperbClass}">something</div>'
    context = new Wingman.Object
    context.set myAwesomeClass: 'user', mySuperbClass: 'user'

    element = template(context)[0]

    context.set mySuperbClass: 'premium'
    @assertElementHasClass element, 'user'
    @assertElementHasClass element, 'premium'
