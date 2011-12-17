Janitor = require('janitor')
Module = require('../lib/module')
Events = require('../lib/events')

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
  
      @assert_equal 'works?', received_arg
