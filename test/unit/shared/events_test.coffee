Janitor = require 'janitor'
Module = require '../../../lib/wingman/shared/module'
Events = require '../../../lib/wingman/shared/events'

module.exports = class extends Janitor.TestCase
  'test trigger': ->
    klass = class extends Module
      @include Events
    
    instance = new klass
    triggered = triggered2 = false

    instance.bind 'something', -> triggered = true
    instance.bind 'something', -> triggered2 = true

    instance.trigger 'something'

    @assert triggered
    @assert triggered2
  
  'test trigger arguments': ->
      klass = class extends Module
        @include Events
      
      instance = new klass
      received_arg = false
  
      instance.bind 'something', (arg) -> received_arg = arg
      instance.trigger 'something', 'works?'
  
      @assertEqual 'works?', received_arg

  'test unbind': ->
    klass = class extends Module
      @include Events
    
    instance = new klass
    triggered = false
    callback = -> triggered = true
    instance.bind 'something', callback
    instance.unbind 'something', callback
    instance.trigger 'something'
    @assert !triggered
