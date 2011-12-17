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
    @getProperties()[property_name] = value

  getProperties: ->
    @properties ||= {}

  get: (property_name) ->
    @getProperties()[property_name]
