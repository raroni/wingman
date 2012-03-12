Module = require './module'
Events = require './events'

property_dependencies = {}

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
      property_dependencies[@] ||= @buildPropertyDependencies()
    
  @addPropertyDependencies: (hash) ->
    config = @propertyDependencies()
    config[key] = value for key, value of hash
  
  constructor: ->
    @initPropertyDependencies() if @constructor.propertyDependencies()
  
  initPropertyDependencies: ->
    for dependent_property_key, depending_properties_keys of @constructor.propertyDependencies()
      depending_properties_keys = [depending_properties_keys] unless Array.isArray(depending_properties_keys)
      for depending_property_key in depending_properties_keys
        @initPropertyDependency dependent_property_key, depending_property_key
  
  initPropertyDependency: (dependent_property_key, depending_property_key) ->
    trigger = => @triggerPropertyChange dependent_property_key
    @observe depending_property_key, (new_value, old_value) =>
      trigger()
      
      if !old_value?.forEach && new_value?.forEach
        observeArrayLike()
      else if old_value?.forEach
        unobserveArrayLike()
    
    observeArrayLike = =>
      @observe depending_property_key, 'add', trigger
      @observe depending_property_key, 'remove', trigger
    
    unobserveArrayLike = =>
      @unobserve depending_property_key, 'add', trigger
      @unobserve depending_property_key, 'remove', trigger
  
  set: (hash) ->
    @setProperties hash

  setProperties: (hash) ->
    for property_name, value of hash
      @setProperty property_name, value
  
  triggerPropertyChange: (property_name) ->
    @previous_properties ||= {}
    new_value = @get property_name
    if !@previous_properties.hasOwnProperty(property_name) || @previous_properties[property_name] != new_value
      @trigger "change:#{property_name}", new_value, @previous_properties[property_name]
      @previous_properties[property_name] = new_value
  
  observeOnce: (chain_as_string, callback) ->
    observer = (args...) =>
      callback args...
      @unobserve chain_as_string, observer
      
    @observe chain_as_string, observer
  
  observe: (chain_as_string, args...) ->
    # Beware, all ye who enter, for here be dragons!
    callback = args.pop()
    type = args.pop() || 'change'
    
    chain = chain_as_string.split '.'
    chain_except_first = chain.slice 1, chain.length
    chain_except_first_as_string = chain_except_first.join '.'
    nested = chain_except_first.length != 0
    
    get_and_send_to_callback = (new_value, old_value) =>
      if type == 'change'
        callback new_value, old_value
      else
        callback new_value
    
    property = @get chain[0]
    
    observeOnNested = (p) =>
      p.observe chain_except_first_as_string, type, (new_value, old_value) ->
        get_and_send_to_callback new_value, old_value
    
    observeOnNested(property) if nested && property
    
    observe_type = if nested then 'change' else type
    @observeProperty chain[0], observe_type, (new_value, old_value) ->
      if nested
        if new_value
          ov = if old_value then old_value.get(chain_except_first.join('.')) else undefined
          get_and_send_to_callback new_value.get(chain_except_first.join('.')), ov if type == 'change'
          observeOnNested new_value
        if old_value
          old_value.unobserve chain_except_first_as_string, type, get_and_send_to_callback
      else
        get_and_send_to_callback new_value, old_value
  
  observeProperty: (property_name, type, callback) ->
    @bind "#{type}:#{property_name}", callback

  unobserve: (property_name, args...) ->
    callback = args.pop()
    type = args.pop() || 'change'
    @unbind "#{type}:#{property_name}", callback

  setProperty: (property_name, value) ->
    value = @convertIfNecessary value
    
    @registerPropertySet property_name
    @[property_name] = value
    @triggerPropertyChange property_name
    
    parent = @
    if Array.isArray @[property_name]
      for value, i in @[property_name]
        @[property_name][i] = @convertIfNecessary value
      @addTriggersToArray property_name
  
  # Without this, we wouldn't be able to make an appropriate #toJSON.
  registerPropertySet: (property_name) ->
    @setPropertyNames().push property_name
  
  setPropertyNames: ->
    @set_property_names ||= []
  
  get: (chain_as_string) ->
    chain = chain_as_string.split '.'
    if chain.length == 1
      @getProperty chain[0]
    else
      nested_property_name = chain.shift()
      nested_property = @getProperty nested_property_name
      if nested_property
        nested_property.get chain.join('.')
      else
        undefined
  
  getProperty: (property_name) ->
    if typeof(@[property_name]) == 'function'
      @[property_name].apply @
    else
      @[property_name]
  
  toJSON: (options = {}) ->
    options.only = [options.only] if options.only && !Array.isArray options.only
    
    json = {}
    for property_name in @setPropertyNames()
      should_be_included = (
        (!options.only || (property_name in options.only)) &&
        @serializable(@get(property_name))
      )
      json[property_name] = @get property_name if should_be_included
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
  
  addTriggersToArray: (property_name) ->
    parent = @
    array = @[property_name]
    array.push = ->
      Array.prototype.push.apply @, arguments
      parent.trigger "add:#{property_name}", arguments['0']
    
    array.remove = (value) ->
      index = @indexOf value
      if index != -1
        @splice index, 1
        parent.trigger "remove:#{property_name}", value

module.exports = WingmanObject