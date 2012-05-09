WingmanObject = require './../shared/object'
Events = require './../shared/events'

Scope = WingmanObject.extend
  initialize: (@collection, @params) ->
    @models = {}
    @collection.forEach (model) => @check model
    @collection.bind 'add', @listen, @
  
  listen: (model) ->
    @check model
    
    # If of the relevant properties changes, we need to do a check.
    for key in Object.keys(@params)
      model.observe key, => @check(model)
  
  # Check whether a model should be removed from or added to the scope.
  check: (model) ->
    if @shouldBeAdded(model)
      @add model
    else if @shouldBeRemoved(model)
      @remove model
  
  shouldBeAdded: (model) ->
    @matches(model) && !@exists(model)
  
  shouldBeRemoved: (model) ->
    !@matches(model) && @exists(model)
  
  add: (model) ->
    throw new Error('Model must have ID to be stored.') unless model.id
    throw new Error("#{model.constructor.name} model with ID #{model.id} already in scope.") if @exists(model)
    @models[model.id] = model
    @trigger 'add', model
    model.bind 'destroy', @remove, @
  
  matches: (model) ->
    Object.keys(@params).every (key) =>
      model.get(key) == @params[key]
  
  count: ->
    Object.keys(@models).length
  
  find: (id) ->
    @models[id] || throw new Error 'Model not found in scope.'
  
  remove: (model) ->
    delete @models[model.id]
    model.unbind 'destroy', @remove, @
    @trigger 'remove', model
  
  exists: (model) ->
    !!@models[model.id]
  
  forEach: (callback) ->
    callback value for key, value of @models

Scope.prototype.include Events

module.exports = Scope

