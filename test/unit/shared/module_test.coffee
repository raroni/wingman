Janitor = require 'janitor'
Module = require '../../../lib/wingman/shared/module'

test_module =
  testMethod: ->
    'result'

module.exports = class extends Janitor.TestCase
  'test include': ->
    klass = class extends Module
      @include test_module

    instance = new klass

    @assert instance.testMethod
    @assertEqual 'function', typeof(instance.testMethod)
  
  'test extend': ->
    klass = class extends Module
      @extend test_module

    @assert klass.testMethod
    @assertEqual 'function', typeof(klass.testMethod)
