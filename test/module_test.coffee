Janitor = require('janitor')
Module = require('../lib/module')

module.exports = class extends Janitor.TestCase
  setup: ->
    @test_module = {
      testMethod: ->
        'result'
    }

  'test include': ->
    a = @test_module
    klass = class extends Module
      @include a

    instance = new klass

    @assert instance.testMethod
    @assert_equal 'function', typeof(instance.testMethod)
  
  'test extend': ->
    a = @test_module
    klass = class extends Module
      @extend a

    @assert klass.testMethod
    @assert_equal 'function', typeof(klass.testMethod)
