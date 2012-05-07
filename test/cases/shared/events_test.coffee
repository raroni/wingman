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
  
  'test bind with context': ->
    module =
      x: 20
      doubleX: -> @x *= 2
    
    klass = WingmanObject.extend include: Events
    instance = klass.create()
    instance.bind 'something', module.doubleX, module
    
    instance.trigger 'something'
    
    @assertEqual 40, module.x
  
  'test unbind with context': ->
    callbackValues = []
    
    module =
      myNumber: 20
      registerNumber: -> callbackValues.push @myNumber
    
    klass = WingmanObject.extend include: Events
    instance = klass.create()
    instance.bind 'something', module.registerNumber, module
    instance.bind 'something', module.registerNumber
    
    instance.unbind 'something', module.registerNumber, module
    
    instance.trigger 'something'
    
    @assertEqual 1, callbackValues.length
    @assertEqual undefined, callbackValues[0]
