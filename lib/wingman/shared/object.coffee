Module = require './module'
Events = require './events'

propertyDependencies = {}

WingmanObject = class WingmanObject extends Module
  @include Events
  
  @parentPropertyDependencies: ->
    if @__super__?.constructor?.propertyDependencies
      @__super__.constructor.propertyDependencies()
    else
      {}
  
  @buildPropertyDependencies: ->
    dependencies = {}
    dependencies[key] = value for key, value of @parentPropertyDependencies()
    dependencies
  
  @propertyDependencies: (hash) ->
    if hash
      @addPropertyDependencies hash
    else
      propertyDependencies[@] ||= @buildPropertyDependencies()
    
  @addPropertyDependencies: (hash) ->
    config = @propertyDependencies()
    config[key] = value for key, value of hash
  
  constructor: ->
    @initPropertyDependencies() if @constructor.propertyDependencies()
  
  initPropertyDependencies: ->
    for dependentPropertyKey, dependingPropertiesKeys of @constructor.propertyDependencies()
      dependingPropertiesKeys = [dependingPropertiesKeys] unless Array.isArray(dependingPropertiesKeys)
      for dependingPropertyKey in dependingPropertiesKeys
        @initPropertyDependency dependentPropertyKey, dependingPropertyKey
  
  initPropertyDependency: (dependentPropertyKey, dependingPropertyKey) ->
    trigger = => @triggerPropertyChange dependentPropertyKey
    @observe dependingPropertyKey, (newValue, oldValue) =>
      trigger()
      
      if !oldValue?.forEach && newValue?.forEach
        observeArrayLike()
      else if oldValue?.forEach
        unobserveArrayLike()
    
    observeArrayLike = =>
      @observe dependingPropertyKey, 'add', trigger
      @observe dependingPropertyKey, 'remove', trigger
    
    unobserveArrayLike = =>
      @unobserve dependingPropertyKey, 'add', trigger
      @unobserve dependingPropertyKey, 'remove', trigger
  
  set: (hash) ->
    @setProperties hash

  setProperties: (hash) ->
    for propertyName, value of hash
      @setProperty propertyName, value
  
  triggerPropertyChange: (propertyName) ->
    @previousProperties ||= {}
    newValue = @get propertyName
    if !@previousProperties.hasOwnProperty(propertyName) || @previousProperties[propertyName] != newValue
      @trigger "change:#{propertyName}", newValue, @previousProperties[propertyName]
      @previousProperties[propertyName] = newValue
  
  observeOnce: (chainAsString, callback) ->
    observer = (args...) =>
      callback args...
      @unobserve chainAsString, observer
      
    @observe chainAsString, observer
  
  observe: (chainAsString, args...) ->
    # Beware, all ye who enter, for here be dragons!
    callback = args.pop()
    type = args.pop() || 'change'
    
    chain = chainAsString.split '.'
    chainExceptFirst = chain.slice 1, chain.length
    chainExceptFirstAsString = chainExceptFirst.join '.'
    nested = chainExceptFirst.length != 0
    
    getAndSendToCallback = (newValue, oldValue) =>
      if type == 'change'
        callback newValue, oldValue
      else
        callback newValue
    
    property = @get chain[0]
    
    observeOnNested = (p) =>
      p.observe chainExceptFirstAsString, type, (newValue, oldValue) ->
        getAndSendToCallback newValue, oldValue
    
    observeOnNested(property) if nested && property
    
    observeType = if nested then 'change' else type
    @observeProperty chain[0], observeType, (newValue, oldValue) ->
      if nested
        if newValue
          ov = if oldValue then oldValue.get(chainExceptFirst.join('.')) else undefined
          getAndSendToCallback newValue.get(chainExceptFirst.join('.')), ov if type == 'change'
          observeOnNested newValue
        if oldValue
          oldValue.unobserve chainExceptFirstAsString, type, getAndSendToCallback
      else
        getAndSendToCallback newValue, oldValue
  
  observeProperty: (propertyName, type, callback) ->
    @bind "#{type}:#{propertyName}", callback

  unobserve: (propertyName, args...) ->
    callback = args.pop()
    type = args.pop() || 'change'
    @unbind "#{type}:#{propertyName}", callback

  setProperty: (propertyName, value) ->
    value = @convertIfNecessary value
    
    @registerPropertySet propertyName
    @[propertyName] = value
    @triggerPropertyChange propertyName
    
    parent = @
    if Array.isArray @[propertyName]
      for value, i in @[propertyName]
        @[propertyName][i] = @convertIfNecessary value
      @addTriggersToArray propertyName
  
  # Without this, we wouldn't be able to make an appropriate #toJSON.
  registerPropertySet: (propertyName) ->
    @setPropertyNames().push propertyName
  
  setPropertyNames: ->
    @_setPropertyNames ||= []
  
  get: (chainAsString) ->
    chain = chainAsString.split '.'
    if chain.length == 1
      @getProperty chain[0]
    else
      nestedPropertyName = chain.shift()
      nestedProperty = @getProperty nestedPropertyName
      if nestedProperty
        nestedProperty.get chain.join('.')
      else
        undefined
  
  getProperty: (propertyName) ->
    if typeof(@[propertyName]) == 'function'
      @[propertyName].apply @
    else
      @[propertyName]
  
  toJSON: (options = {}) ->
    options.only = [options.only] if options.only && !Array.isArray options.only
    
    json = {}
    for propertyName in @setPropertyNames()
      shouldBeIncluded = (
        (!options.only || (propertyName in options.only)) &&
        @serializable(@get(propertyName))
      )
      json[propertyName] = @get propertyName if shouldBeIncluded
    json
  
  serializable: (value) ->
    (typeof(value) in ['number', 'string']) || @convertable(value)
  
  convertIfNecessary: (value) ->
    if @convertable(value)
      wo = new WingmanObject
      wo.set value
      wo
    else
      value
  
  convertable: (value) ->
    typeof(value) == 'object' &&
    value?.constructor? &&
    value.constructor.name == 'Object' &&
    (!(value instanceof WingmanObject)) &&
    !value?._ownerDocument? # need this to detect jsdom HTMLElement values - is there a better way?
  
  createSubContext: ->
    Object.create @
  
  addTriggersToArray: (propertyName) ->
    parent = @
    array = @[propertyName]
    array.push = ->
      Array.prototype.push.apply @, arguments
      parent.trigger "add:#{propertyName}", arguments['0']
    
    array.remove = (value) ->
      index = @indexOf value
      if index != -1
        @splice index, 1
        parent.trigger "remove:#{propertyName}", value

module.exports = WingmanObject
