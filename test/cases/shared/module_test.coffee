Janitor = require 'janitor'
Module = require '../../../lib/wingman-client/shared/module'

module.exports = class extends Janitor.TestCase
  'test include': ->
    TestModule = { testMethod: -> 'result' }

    klass = class extends Module
      @include TestModule
    
    instance = new klass
    
    @assert instance.testMethod
    @assertEqual 'function', typeof(instance.testMethod)
  
  'test included callback': ->
    callbackValue = undefined
    TestModule =
      included: (base) ->
        callbackValue = base
    
    klass = class extends Module
      @include TestModule
    
    @assertEqual callbackValue, klass
  
  'test extend': ->
    TestModule = { testMethod: -> 'result' }
    
    klass = class extends Module
      @extend TestModule
    
    @assert klass.testMethod
    @assertEqual 'function', typeof(klass.testMethod)

  'test extended callback': ->
    callbackValue = undefined
    TestModule =
      extended: (base) ->
        callbackValue = base

    klass = class extends Module
      @extend TestModule

    @assertEqual callbackValue, klass
