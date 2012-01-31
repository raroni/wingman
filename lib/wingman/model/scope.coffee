Module = require './../shared/module'
Events = require './../shared/events'

module.exports = class Scope extends Module
  @include Events
  
  constructor: (store, @params) ->
    @models = {}
    store.bind 'add', @checkAdd
  
  checkAdd: (model) =>
    @add model if @isValid(model)
  
  add: (model) ->
    throw new Error('Model must have ID to be stored.') unless model.get('id')
    @models[model.get('id')] = model
    @trigger 'add', model
    model.bind 'destroy', @remove
  
  isValid: (model) ->
    Object.keys(@params).every (key) =>
      model.get(key) == @params[key]
  
  count: ->
    Object.keys(@models).length
  
  find: (id) ->
    @models[id]
  
  remove: (model) =>
    delete @models[model.get('id')]
    model.unbind @remove
    @trigger 'remove', model
