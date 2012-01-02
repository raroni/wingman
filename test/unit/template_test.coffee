Janitor = require 'janitor'
Wingman = require '../..'
document = require('jsdom').jsdom()
CustomAssertions = require '../custom_assertions'

module.exports = class extends Janitor.TestCase
  setup: ->
    Wingman.Template.document = document
  
  assertElementHasClass: CustomAssertions.assertDOMElementHasClass
  refuteElementHasClass: CustomAssertions.refuteDOMElementHasClass
  
  'test basic template with static value': ->
    template = Wingman.Template.compile '<div>hello</div>'
    elements = template()
    @assert_equal 1, elements.length
    @assert_equal 'hello', elements[0].innerHTML

  'test template with nested tags': ->
    template = Wingman.Template.compile '<ol><li>hello</li></ol>'
    elements = template()

    @assert_equal 1, elements.length
    ol_elm = elements[0]
    @assert_equal 1, ol_elm.childNodes.length
    @assert_equal 'hello', ol_elm.childNodes[0].innerHTML

  'test basic template with dynamic content': ->
    template = Wingman.Template.compile '<div>{greeting}</div>'
    context = new Wingman.Object
    context.set greeting: 'hello'
    elements = template context
    @assert_equal 1, elements.length
    @assert_equal 'hello', elements[0].innerHTML

  'test template with dynamic value after updating context': ->
    template = Wingman.Template.compile '<div>{greeting}</div>'
    context = new Wingman.Object
    context.set greeting: 'hello'
    elements = template context
    context.set greeting: 'hi'

    @assert_equal 1, elements.length
    @assert_equal 'hi', elements[0].innerHTML

  'test template with nested dynamic value after updating context': ->
    template = Wingman.Template.compile '<div>{user.name}</div>'
    user = new Wingman.Object
    user.set name: 'Rasmus'
    context = new Wingman.Object
    context.set {user}
    elements = template context
    
    @assert_equal 1, elements.length
    @assert_equal 'Rasmus', elements[0].innerHTML
    
    user.set name: 'John'
    @assert_equal 'John', elements[0].innerHTML

  'test for token': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'

    context = new Wingman.Object
    context.set users: ['Rasmus', 'John']
    elements = template context

    @assert_equal 1, elements.length

    ol_elm = elements[0]
    @assert_equal 2, ol_elm.childNodes.length
    @assert_equal 'Rasmus', ol_elm.childNodes[0].innerHTML
    @assert_equal 'John', ol_elm.childNodes[1].innerHTML

  'test for token with deferred push': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'

    context = new Wingman.Object
    context.set users: ['Rasmus', 'John']
    elements = template context

    ol_elm = elements[0]
    @assert_equal 2, ol_elm.childNodes.length

    context.get('users').push 'Oliver'
    @assert_equal 3, ol_elm.childNodes.length
    @assert_equal 'Oliver', ol_elm.childNodes[2].innerHTML

  'test for token with deferred remove': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'

    context = new Wingman.Object
    context.set users: ['Rasmus', 'John']
    elements = template context

    ol_elm = elements[0]
    @assert_equal 2, ol_elm.childNodes.length

    context.get('users').remove 'John'
    @assert_equal 1, ol_elm.childNodes.length

  'test for token with deferred reset': ->
    template = Wingman.Template.compile '<ol>{for users}<li>{user}</li>{end}</ol>'

    context = new Wingman.Object
    context.set users: ['Rasmus', 'John']
    elements = template context
    ol_elm = elements[0]
    context.set users: ['Oliver']
    @assert_equal 1, ol_elm.childNodes.length
    @assert_equal 'Oliver', ol_elm.childNodes[0].innerHTML
  
  'test element with single static style': ->
    template = Wingman.Template.compile '<div style="color:red">yo</div>'
    elements = template()

    @assert_equal 'red', elements[0].style.color

  'test element with single dynamic style': ->
    template = Wingman.Template.compile '<div style="color:{color}">yo</div>'
    context = new Wingman.Object
    context.set color: 'red'
    elements = template context

    @assert_equal 'red', elements[0].style.color

  'test deferred reset for element with single dynamic style': ->
    template = Wingman.Template.compile '<div style="color:{myColor}">yo</div>'
    context = new Wingman.Object
    context.set myColor: 'red'
    elements = template context
    context.set myColor: 'blue'
    @assert_equal 'blue', elements[0].style.color

  'test element with two static styles': ->
    template = Wingman.Template.compile '<div style="color:{myColor}; font-size: 15px">yo</div>'
    context = new Wingman.Object
    context.set myColor: 'red'
    elements = template context

    @assert_equal 'red', elements[0].style.color
    @assert_equal '15px', elements[0].style.fontSize
  
  'test element with two dynamic styles': ->
    template = Wingman.Template.compile '<div style="color:{myColor}; font-size: {myFontSize}">yo</div>'
    context = new Wingman.Object
    context.set myColor: 'red', myFontSize: '15px'
    elements = template context

    @assert_equal 'red', elements[0].style.color
    @assert_equal '15px', elements[0].style.fontSize

    context.set myColor: 'blue', myFontSize: '13px'
    @assert_equal 'blue', elements[0].style.color
    @assert_equal '13px', elements[0].style.fontSize

  'test element with single static class': ->
    template = Wingman.Template.compile '<div class="user">something</div>'
    element = template()[0]
    @assertElementHasClass element, 'user'

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

  'test deferred update with element with single dynamic class': ->
    template = Wingman.Template.compile '<div class="{myAwesomeClass}">something</div>'
    context = new Wingman.Object
    context.set myAwesomeClass: 'user'

    element = template(context)[0]
    @assertElementHasClass element, 'user'

    context.set myAwesomeClass: 'something_else'

    @assertElementHasClass element, 'something_else'
    @refuteElementHasClass element, 'user'
