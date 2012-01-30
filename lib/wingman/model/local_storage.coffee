Wingman = require '../../wingman'

module.exports = class
  auto_save: true
  
  constructor: (@options) ->
  
  create: (model, options) ->
    model.set id: @generateId()
    Wingman.localStorage.setItem @key(model), JSON.stringify(model.toJSON())
    options?.success?()
    
  update: (model, options) ->
    @load model, success: (existing_properties) =>
      new_properties = model.toJSON()
      for key, value of existing_properties
        new_properties[key] = value unless new_properties[key]?
      Wingman.localStorage.setItem @key(model), JSON.stringify(new_properties)
      options?.success?()
  
  load: (model, options) ->
    item_as_string = Wingman.localStorage.getItem @key(model)
    item_as_json = JSON.parse item_as_string
    options.success item_as_json
  
  key: (model) ->
    [@options.namespace, model.get('id')].join '.'
  
  generateId: ->
    Math.round Math.random()*5000000
