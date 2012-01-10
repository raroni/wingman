Janitor = require 'janitor'
Value = require '../../../../lib/wingman/template/parser/value'
RangoObject = require '../../../../lib/wingman/object'

module.exports = class extends Janitor.TestCase
  'test static': ->
    value = new Value 'test'
    @assertEqual 'test', value.get()
    @assert !value.is_dynamic

  'test dynamic': ->
    value = new Value '{something}'
    @assert value.is_dynamic

    context = new RangoObject
    context.set something: 'my value'

    @assertEqual 'my value', value.get(context)
    @assertEqual 'something', value.get()
