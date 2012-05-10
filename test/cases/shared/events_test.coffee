Janitor = require 'janitor'
WingmanObject = require '../../../lib/wingman/shared/object'
Events = require '../../../lib/wingman/shared/events'

newEventable = ->
  Constructor = WingmanObject.extend()
  Constructor.include Events
  new Constructor

module.exports = class extends Janitor.TestCase
  'test trigger': ->
    instance = newEventable()
    triggered = triggered2 = false
    
    instance.bind 'something', -> triggered = true
    instance.bind 'something', -> triggered2 = true
    
    instance.trigger 'something'
    
    @assert triggered
    @assert triggered2
  
  'test trigger arguments': ->
    instance = newEventable()
    
    receivedArg = false
    instance.bind 'something', (arg) -> receivedArg = arg
    instance.trigger 'something', 'works?'
    
    @assertEqual 'works?', receivedArg
  
  'test unbind': ->
    instance = newEventable()
    
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
    
    instance = newEventable()
    
    instance.bind 'something', module.doubleX, module
    
    instance.trigger 'something'
    
    @assertEqual 40, module.x
  
  'test unbind with context': ->
    callbackValues = []
    
    module =
      myNumber: 20
      registerNumber: -> callbackValues.push @myNumber
    
    instance = newEventable()
    
    instance.bind 'something', module.registerNumber, module
    instance.bind 'something', module.registerNumber
    
    instance.unbind 'something', module.registerNumber, module
    
    instance.trigger 'something'
    
    @assertEqual 1, callbackValues.length
    @assertEqual undefined, callbackValues[0]
