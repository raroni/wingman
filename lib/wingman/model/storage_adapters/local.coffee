Wingman = require '../../../wingman'

module.exports = class
  auto_save: true
  
  constructor: (@options) ->
  
  create: (model, options) ->
    model.set id: @generateId()
    Wingman.localStorage.setItem @key(model.get('id')), JSON.stringify(model.toJSON())
    options?.success?()
    
  update: (model, options) ->
    @load model.get('id'), success: (existing_properties) =>
      new_properties = model.toJSON()
      for key, value of existing_properties
        new_properties[key] = value unless new_properties[key]?
      Wingman.localStorage.setItem @key(model.get('id')), JSON.stringify(new_properties)
      options?.success?()
  
  load: (id, options) ->
    item_as_string = Wingman.localStorage.getItem @key(id)
    item_as_json = JSON.parse item_as_string
    options.success item_as_json
  
  key: (id) ->
    [@options.namespace, id].join '.'
  
  generateId: ->
    Math.round Math.random()*5000000
