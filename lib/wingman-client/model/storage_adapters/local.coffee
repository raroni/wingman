Wingman = require '../../../wingman-client'

module.exports = class
  autoSave: true
  
  constructor: (@options) ->
  
  create: (model, options) ->
    model.set id: @generateId()
    Wingman.localStorage.setItem @key(model.get('id')), JSON.stringify(model.toJSON())
    options?.success?()
    
  update: (model, options) ->
    @load model.get('id'), success: (existingProperties) =>
      newProperties = model.toJSON()
      for key, value of existingProperties
        newProperties[key] = value unless newProperties[key]?
      Wingman.localStorage.setItem @key(model.get('id')), JSON.stringify(newProperties)
      options?.success?()
  
  load: (id, options) ->
    itemAsString = Wingman.localStorage.getItem @key(id)
    itemAsJson = JSON.parse itemAsString
    options.success itemAsJson
  
  key: (id) ->
    [@options.namespace, id].join '.'
  
  generateId: ->
    Math.round Math.random()*5000000
