Janitor = require 'janitor'
Rango = require '../rango'

module.exports = class extends Janitor.TestCase
  'test simple set/get': ->
    klass = class extends Rango.Object
    instance = new klass
    instance.set name: 'rasmus'
    @assert_equal 'rasmus', instance.get('name')
