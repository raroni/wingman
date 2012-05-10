WingmanObject = require './../shared/object'
Events = require './../shared/events'
Scope = require './scope'

module.exports = WingmanObject.extend
  include: Events
  
  initialize: ->
    @models = {}
  
  add: (model) ->
    throw new Error('Model must have ID to be stored.') unless model.id
    if @exists model
      @update @models[model.id], model
    else
      @insert model
  
  insert: (model) ->
    @models[model.get('id')] = model
    @trigger 'add', model
    model.bind 'flush', @remove, @
  
  update: (model, model2) ->
    for key, value of model2.toJSON()
      model[key] = value unless key == 'id'
  
  find: (id) ->
    @models[id]
  
  count: ->
    Object.keys(@models).length
  
  remove: (model) ->
    delete @models[model.id]
    model.unbind @remove, @
    @trigger 'remove', model
  
  exists: (model) ->
    !!@models[model.get('id')]
  
  forEach: (callback) ->
    callback(value) for key, value of @models
  
  scoped: (params) ->
    new Scope @, params
  
  flush: ->
    @forEach (model) -> model.flush()
