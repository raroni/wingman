module.exports =
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
  
    getAndSendToCallback = (newValue, oldValue) =>
      if type == 'change'
        callback newValue, oldValue
      else
        callback newValue
  
    property = @[chain[0]]
  
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
