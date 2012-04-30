Properties = require '../object/properties'

module.exports =
  initialize: ->
    @initPropertyDependencies() if @constructor.propertyDependencies
    @[key] = value for key, value of arguments[0]
  
  get: (chainAsString) ->
    chain = chainAsString.split '.'
    if chain.length == 1
      @[chain[0]]
    else
      nestedPropertyName = chain.shift()
      nestedProperty = @[nestedPropertyName]
      if nestedProperty
        nestedProperty.get chain.join('.')
      else
        undefined
  
  set: (hash) ->
    @[key] = value for key, value of hash
  
  triggerPropertyChange: (propertyName) ->
    @previousProperties ||= {}
    newValue = @[propertyName]
    if !@previousProperties.hasOwnProperty(propertyName) || @previousProperties[propertyName] != newValue
      @trigger "change:#{propertyName}", newValue, @previousProperties[propertyName]
      @previousProperties[propertyName] = newValue

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
      p.observe chainExceptFirstAsString, type, (newValue, oldValue) ->
        callback newValue, oldValue
    
    observeEnumerable = (property) ->
      property.bind type, callback
    
    checkProperty = (property) ->
      if nested
        observeNested property
      else if type != 'change'
        observeEnumerable property
    
    checkProperty property if property
    
    @observeProperty chain[0], 'change', (newValue, oldValue) ->
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
  
  observeProperty: (propertyName, type, callback) ->
    @bind "#{type}:#{propertyName}", callback
  
  unobserve: (propertyName, args...) ->
    callback = args.pop()
    type = args.pop() || 'change'
    @unbind "#{type}:#{propertyName}", callback
  
  initPropertyDependencies: ->
    for dependentPropertyKey, dependingPropertiesKeys of @constructor.propertyDependencies()
      dependingPropertiesKeys = [dependingPropertiesKeys] unless Array.isArray(dependingPropertiesKeys)
      for dependingPropertyKey in dependingPropertiesKeys
        @initPropertyDependency dependentPropertyKey, dependingPropertyKey
  
  initPropertyDependency: (dependentPropertyKey, dependingPropertyKey) ->
    trigger = =>
      @triggerPropertyChange dependentPropertyKey
    
    @observe dependingPropertyKey, (newValue, oldValue) =>
      trigger()
      
      if !oldValue?.forEach && newValue?.forEach
        newValue.bind 'add', trigger
        newValue.bind 'remove', trigger
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
  
  superMethod: (propertyName) ->
    Object.getPrototypeOf(Object.getPrototypeOf(@))[propertyName].bind(@)()

isSerializable = (value) ->
  typeof(value) in ['number', 'string']

