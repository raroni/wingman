Janitor = require 'janitor'
WingmanObject = require '../../../lib/wingman/shared/object'
Events = require '../../../lib/wingman/shared/events'

module.exports = class extends Janitor.TestCase
  @solo: true
  
  'test trigger': ->
    klass = WingmanObject.extend include: Events
    instance = klass.create()
    triggered = triggered2 = false
    
    instance.bind 'something', -> triggered = true
    instance.bind 'something', -> triggered2 = true
    
    instance.trigger 'something'
    
    @assert triggered
    @assert triggered2
  
  'test trigger arguments': ->
    klass = WingmanObject.extend include: Events
    instance = klass.create()
    
    receivedArg = false
    instance.bind 'something', (arg) -> receivedArg = arg
    instance.trigger 'something', 'works?'
    
    @assertEqual 'works?', receivedArg
  
  'test unbind': ->
    klass = WingmanObject.extend include: Events
    
    instance = klass.create()
    triggered = false
    callback = -> triggered = true
    instance.bind 'something', callback
    instance.unbind 'something', callback
    instance.trigger 'something'
    @assert !triggered
