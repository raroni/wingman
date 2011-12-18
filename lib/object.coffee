Module = require './module'
Events = require './events'

module.exports = class extends Module
  @include Events

  set: (hash) ->
    @setProperties hash

  setProperties: (hash) ->
    for property_name, value of hash
      @setProperty property_name, value

  observe: (chain_as_string, callback) ->
    chain = chain_as_string.split '.'
    chain_except_first = chain.slice 1, chain.length
    chain_except_first_as_string = chain_except_first.join '.'

    get_and_send_to_callback = =>
      callback @get(chain_as_string)

    if chain_except_first.length != 0
      property = @get chain[0]
      property.observe chain_except_first_as_string, get_and_send_to_callback

    @observeProperty chain[0], (new_value) ->
      get_and_send_to_callback()
      if chain_except_first.length != 0
        property.unobserve chain_except_first_as_string, get_and_send_to_callback
        new_value.observeProperty chain_except_first_as_string, get_and_send_to_callback
  
  observeProperty: (property_name, callback) ->
    @bind "change:#{property_name}", callback

  unobserve: (property_name, callback) ->
    @unbind "change:#{property_name}", callback

  setProperty: (property_name, value) ->
    @[property_name] = value
    @trigger "change:#{property_name}", value

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
