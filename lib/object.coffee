Module = require './module'
Events = require './events'

module.exports = class extends Module
  @include Events

  set: (hash) ->
    @setProperties hash

  setProperties: (hash) ->
    for property_name, value of hash
      @setProperty property_name, value

  observe: (property_name, callback) ->
    @bind "change:#{property_name}", callback

  setProperty: (property_name, value) ->
    @[property_name] = value
    @trigger "change:#{property_name}", value

  get: (property_name) ->
    if typeof(@[property_name]) == 'function'
      @[property_name].apply @
    else
      @[property_name]
