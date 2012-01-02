Janitor = require 'janitor'
Value = require '../../../../lib/wingman/template/parser/value'
RangoObject = require '../../../../lib/wingman/object'

module.exports = class extends Janitor.TestCase
  'test static': ->
    value = new Value 'test'
    @assert_equal 'test', value.get()
    @assert !value.is_dynamic

  'test dynamic': ->
    value = new Value '{something}'
    @assert value.is_dynamic

    context = new RangoObject
    context.set something: 'my value'

    @assert_equal 'my value', value.get(context)
    @assert_equal 'something', value.get()
