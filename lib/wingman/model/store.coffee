Module = require './../shared/module'
Events = require './../shared/events'

module.exports = class Store extends Module
  @include Events
  
  constructor: ->
    @models = {}
  
  add: (model) ->
    throw new Error('Model must have ID to be stored.') unless model.get('id')
    @models[model.get('id')] = model
    @trigger 'add', model
    model.bind 'destroy', @remove
  
  count: ->
    Object.keys(@models).length
  
  remove: (model) =>
    delete @models[model.get('id')]
    model.unbind @remove
    @trigger 'remove', model
