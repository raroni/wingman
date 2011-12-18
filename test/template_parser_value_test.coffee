Janitor = require 'janitor'
Value = require '../lib/template/parser/value'
Rango = require '../rango'

module.exports = class extends Janitor.TestCase
  'test static': ->
    value = new Value 'test'
    @assert_equal 'test', value.get()
    @assert !value.is_dynamic

  'test dynamic': ->
    value = new Value '{something}'
    @assert value.is_dynamic
    @assert_equal 'something', value.get()
