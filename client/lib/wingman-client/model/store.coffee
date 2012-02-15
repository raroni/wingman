Module = require './../shared/module'
Events = require './../shared/events'

module.exports = class Store extends Module
  @include Events
  
  constructor: ->
    @models = {}
  
  add: (model) ->
    throw new Error('Model must have ID to be stored.') unless model.get('id')
    if @exists model
      @update @models[model.get('id')], model
    else
      @insert model
  
  insert: (model) ->
    @models[model.get('id')] = model
    @trigger 'add', model
    model.bind 'destroy', @remove
  
  update: (model, model2) ->
    for key, value of model2.toJSON()
      model.setProperty key, value unless key == 'id'
  
  count: ->
    Object.keys(@models).length
  
  remove: (model) =>
    delete @models[model.get('id')]
    model.unbind @remove
    @trigger 'remove', model
  
  exists: (model) ->
    !!@models[model.get('id')]
  
  forEach: (callback) ->
    callback(value) for key, value of @models
