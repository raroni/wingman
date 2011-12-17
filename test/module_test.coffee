Janitor = require('janitor')
Module = require('../lib/module')

test_module =
  testMethod: ->
    'result'

module.exports = class extends Janitor.TestCase
  'test include': ->
    klass = class extends Module
      @include test_module

    instance = new klass

    @assert instance.testMethod
    @assert_equal 'function', typeof(instance.testMethod)
  
  'test extend': ->
    klass = class extends Module
      @extend test_module

    @assert klass.testMethod
    @assert_equal 'function', typeof(klass.testMethod)
