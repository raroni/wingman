Module = require './module'
Events = require './events'

module.exports = class extends Module
  @include Events

  @addPropertyDependencies: (hash) ->
    @_property_dependencies ||= {}
    for property_name, dependent_properties of hash
      @_property_dependencies[property_name] ||= []
      @_property_dependencies[property_name].concat dependent_properties

  set: (hash) ->
    @setProperties hash

  setProperties: (hash) ->
    for property_name, value of hash
      @setProperty property_name, value

  triggerPropertyChangesForDependingProperties: (property, old_value) ->
    # This implementation should probably be cleaned up.
    triggered = {}
    for property_name, dependent_properties of @constructor._property_dependencies
      @triggerPropertyChange property_name, old_value if !triggered[property_name]
      triggered[property_name] = true

  triggerPropertyChange: (property_name, old_value) ->
    @trigger "change:#{property_name}", @get(property_name), old_value

  observe: (chain_as_string, args...) ->
    callback = args.pop()
    type = args.pop() || 'change'

    chain = chain_as_string.split '.'
    chain_except_first = chain.slice 1, chain.length
    chain_except_first_as_string = chain_except_first.join '.'

    get_and_send_to_callback = (new_value, old_value) =>
      if type == 'change'
        callback new_value, old_value
      else
        callback new_value

    @observeProperty chain[0], type, (new_value, old_value) ->
      if chain_except_first.length != 0
        property.unobserve chain_except_first_as_string, type, get_and_send_to_callback
        get_and_send_to_callback new_value.get(chain_except_first.join('.')), old_value.get(chain_except_first.join('.'))
      else
        get_and_send_to_callback new_value, old_value

    if chain_except_first.length != 0
      property = @get chain[0]
      property.observe chain_except_first_as_string, type, (new_value, old_value) ->
        get_and_send_to_callback new_value, old_value
  
  observeProperty: (property_name, type, callback) ->
    @bind "#{type}:#{property_name}", callback

  unobserve: (property_name, args...) ->
    callback = args.pop()
    type = args.pop() || 'change'
    @unbind "#{type}:#{property_name}", callback

  setProperty: (property_name, value) ->
    old_value = @get property_name
    @[property_name] = value
    @triggerPropertyChange property_name, old_value
    @triggerPropertyChangesForDependingProperties property_name, old_value

    parent = @
    if Array.isArray @[property_name]
      @addTriggersToArray property_name

  get: (chain_as_string) ->
    chain = chain_as_string.split '.'
    if chain.length == 1
      @getProperty chain[0]
    else
      nested_property_name = chain.shift()
      @getProperty(nested_property_name).get chain.join('.')
  
  getProperty: (property_name) ->
    if typeof(@[property_name]) == 'function'
      @[property_name].apply @
    else
      @[property_name]

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
