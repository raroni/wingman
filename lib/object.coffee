Module = require './module'
Events = require './events'

module.exports = class extends Module
  @include Events

  set: (hash) ->
    @setProperties hash

  setProperties: (hash) ->
    for property_name, value of hash
      @setProperty property_name, value

  setProperty: (property_name, value) ->
    @[property_name] = value

  get: (property_name) ->
    property = @[property_name]
    if typeof(property) == 'function'
      property.apply @
    else
      property
