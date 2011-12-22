Janitor = require 'janitor'
Rango = require '../rango'

module.exports = class extends Janitor.TestCase
  'test basic template with static value': ->
    template = Rango.Template.compile '<div>hello</div>'
    elements = template()
    @assert_equal 1, elements.length
    @assert_equal 'hello', elements[0].innerHTML

  'test template with nested tags': ->
    template = Rango.Template.compile '<ol><li>hello</li></ol>'
    elements = template()

    @assert_equal 1, elements.length
    ol_elm = elements[0]
    @assert_equal 1, ol_elm.childNodes.length
    @assert_equal 'hello', ol_elm.childNodes[0].innerHTML

  'test basic template with dynamic content': ->
    template = Rango.Template.compile '<div>{greeting}</div>'
    context = new Rango.Object
    context.set greeting: 'hello'
    elements = template context
    @assert_equal 1, elements.length
    @assert_equal 'hello', elements[0].innerHTML

  'test template with dynamic value after updating context': ->
    template = Rango.Template.compile '<div>{greeting}</div>'
    context = new Rango.Object
    context.set greeting: 'hello'
    elements = template context
    context.set greeting: 'hi'

    @assert_equal 1, elements.length
    @assert_equal 'hi', elements[0].innerHTML

  'test template with nested dynamic value after updating context': ->
    template = Rango.Template.compile '<div>{user.name}</div>'
    user = new Rango.Object
    user.set name: 'Rasmus'
    context = new Rango.Object
    context.set {user}
    elements = template context
    
    @assert_equal 1, elements.length
    @assert_equal 'Rasmus', elements[0].innerHTML
    
    user.set name: 'John'
    @assert_equal 'John', elements[0].innerHTML
