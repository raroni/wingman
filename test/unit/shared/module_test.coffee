Janitor = require 'janitor'
Module = require '../../../lib/wingman/shared/module'

module.exports = class extends Janitor.TestCase
  'test include': ->
    TestModule = { testMethod: -> 'result' }

    klass = class extends Module
      @include TestModule
    
    instance = new klass
    
    @assert instance.testMethod
    @assertEqual 'function', typeof(instance.testMethod)
  
  'test included callback': ->
    callback_value = undefined
    TestModule =
      included: (base) ->
        callback_value = base
    
    klass = class extends Module
      @include TestModule
    
    @assertEqual callback_value, klass
  
  'test extend': ->
    TestModule = { testMethod: -> 'result' }
    
    klass = class extends Module
      @extend TestModule
    
    @assert klass.testMethod
    @assertEqual 'function', typeof(klass.testMethod)

  'test extended callback': ->
    callback_value = undefined
    TestModule =
      extended: (base) ->
        callback_value = base

    klass = class extends Module
      @extend TestModule

    @assertEqual callback_value, klass
