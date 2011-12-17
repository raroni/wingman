Janitor = require('janitor')
Module = require('../lib/module')
Events = require('../lib/events')

module.exports = class extends Janitor.TestCase
  'test simple trigger': ->
    klass = class extends Module
      @include Events
    
    instance = new klass
    triggered = false
    instance.bind 'something', ->
      triggered = true
    instance.trigger 'something'

    @assert triggered
