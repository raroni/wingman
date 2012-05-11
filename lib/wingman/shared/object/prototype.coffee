WingmanObject = require '../object'
Events = require '../events'
Properties = require '../object/properties'

observationCallbacks = []
observations = []

Prototype =
  initialize: ->
    @initPropertyDependencies() if @constructor.propertyDependencies
  
  isInstance: ->
    @ instanceof @constructor
  
  observe: (chainAsString, args...) ->
    # Beware, all ye who enter, for here be dragons!
    callback = args.pop()
    type = args.pop() || 'change'
    
    chain = chainAsString.split '.'
    chainExceptFirst = chain.slice 1, chain.length
    chainExceptFirstAsString = chainExceptFirst.join '.'
    nested = chainExceptFirst.length != 0
    
    property = @[chain[0]]
    
    observeNested = (p) =>
      p.observe chainExceptFirstAsString, type, callback
    
    observeEnumerable = (property) ->
      property.bind type, callback
    
    checkProperty = (property) ->
      if property
        if nested
          observeNested property
        else if type != 'change'
          observeEnumerable property
    
    checkProperty property
    
    observation = (newValue, oldValue) ->
      checkProperty newValue
      
      callbackValues = { new: newValue, old: oldValue }
      
      if nested && newValue
        callbackValues.new = newValue.get chainExceptFirstAsString
        callbackValues.old = if oldValue then oldValue.get(chainExceptFirstAsString) else undefined
      
      if oldValue
        if nested
          oldValue.unobserve chainExceptFirstAsString, type, callback
        else if type != 'change'
          oldValue.unbind type, callback
      
      callback callbackValues.new, callbackValues.old if type == 'change'
    
    observations.push observation
    observationCallbacks.push callback
    
    @observeProperty chain[0], 'change', observation
  
  triggerPropertyChange: (propertyName, oldValue) ->
    newValue = @[propertyName]
    @previousProperties = {} unless @hasOwnProperty 'previousProperties'
    if !@previousProperties.hasOwnProperty(propertyName) || @previousProperties[propertyName] != newValue
      @trigger "change:#{propertyName}", newValue, oldValue
      @previousProperties[propertyName] = newValue
  
  observeProperty: (propertyName, type, callback) ->
    @bind "#{type}:#{propertyName}", callback
  
  unobserve: (propertyName, args...) ->
    callback = args.pop()
    index = observationCallbacks.indexOf callback
    if index != -1
      observation = observations[index]
      observations.splice index, 1
      observationCallbacks.splice index, 1
      
      type = args.pop() || 'change'
      @unbind "#{type}:#{propertyName}", observation
  
  initPropertyDependencies: ->
    for dependentPropertyKey, dependingPropertiesKeys of @constructor.propertyDependencies()
      dependingPropertiesKeys = [dependingPropertiesKeys] unless Array.isArray(dependingPropertiesKeys)
      for dependingPropertyKey in dependingPropertiesKeys
        @initPropertyDependency dependentPropertyKey, dependingPropertyKey
  
  initPropertyDependency: (dependentPropertyKey, dependingPropertyKey) ->
    trigger = => @triggerPropertyChange dependentPropertyKey
    
    observeEnumerable = (enumerable) ->
      enumerable.bind 'add', trigger
      enumerable.bind 'remove', trigger
    
    value = @[dependingPropertyKey]
    observeEnumerable value if value && value.forEach
    
    @observe dependingPropertyKey, (newValue, oldValue) =>
      trigger()
      
      if !oldValue?.forEach && newValue?.forEach
        observeEnumerable newValue
      else if oldValue?.forEach
        oldValue.unbind 'add', trigger
        oldValue.unbind 'remove', trigger
  
  toJSON: (options = {}) ->
    json = {}
    properties = Properties.find @
    options.only = [options.only] if options.only && !Array.isArray options.only
    
    for propertyName, propertyValue of properties
      shouldBeIncluded = (
        (!options.only || (propertyName in options.only)) &&
        isSerializable(propertyValue)
      )
      json[propertyName] = propertyValue if shouldBeIncluded
    json
  
  observeOnce: (chainAsString, callback) ->
    observer = (args...) =>
      callback args...
      @unobserve chainAsString, observer
    
    @observe chainAsString, observer
  
  createSubContext: ->
    Object.create @

Prototype[key] = WingmanObject[key] for key in ['include', 'getProperty', 'setProperty', 'set', 'get']
Prototype.include Events

module.exports = Prototype

isSerializable = (value) ->
  typeof(value) in ['number', 'string']
