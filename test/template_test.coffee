Janitor = require 'janitor'
Template = require '../lib/template'

module.exports = class extends Janitor.TestCase
  'test basic template': ->
    template = Template.compile '<div>hello</div>'
    elements = template()
    @assert_equal 1, elements.length
    @assert_equal 'hello', elements[0].innerHTML
