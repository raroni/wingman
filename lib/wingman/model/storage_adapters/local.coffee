Wingman = require '../../../wingman'

module.exports = Wingman.Object.extend
  autoSave: true
  
  initialize: (options) ->
    @namespace = options.namespace
  
  create: (model, options) ->
    model.id = @generateId()
    Wingman.localStorage.setItem @key(model.id), JSON.stringify(model.toJSON())
    options?.success?()
    
  update: (model, options) ->
    @load model.id, success: (existingProperties) =>
      newProperties = model.toJSON()
      for key, value of existingProperties
        newProperties[key] = value unless newProperties[key]?
      Wingman.localStorage.setItem @key(model.id), JSON.stringify(newProperties)
      options?.success?()
  
  load: (id, options) ->
    itemAsString = Wingman.localStorage.getItem @key(id)
    itemAsJson = JSON.parse itemAsString
    options.success itemAsJson
  
  key: (id) ->
    [@namespace, id].join '.'
  
  generateId: ->
    Math.round Math.random()*5000000
  
  delete: (id) ->
    Wingman.localStorage.removeItem @key(id)
