Janitor = require 'janitor'
Rango = require '../rango'

module.exports = class extends Janitor.TestCase
  'test basic template with static value': ->
    template = Rango.Template.compile '<div>hello</div>'
    elements = template()
    @assert_equal 1, elements.length
    @assert_equal 'hello', elements[0].innerHTML

  'test basic template with dynamic content': ->
    template = Rango.Template.compile '<div>{greeting}</div>'
    context = new Rango.Object
    context.set greeting: 'hello'
    elements = template context
    @assert_equal 1, elements.length
    @assert_equal 'hello', elements[0].innerHTML
