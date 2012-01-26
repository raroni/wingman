Wingman = require '../../wingman'

module.exports = class
  auto_save: true
  
  constructor: (@model, @options) ->
  
  create: (options) ->
    @model.set id: @generateId()
    Wingman.localStorage.setItem @key(), JSON.stringify(@model.toJSON())
    options?.success?()
    
  update: (options) ->
    @load success: (existing_properties) =>
      new_properties = @model.toJSON()
      for key, value of existing_properties
        new_properties[key] = value unless new_properties[key]?
      Wingman.localStorage.setItem @key(), JSON.stringify(new_properties)
      options?.success?()
  
  load: (options) ->
    item_as_string = Wingman.localStorage.getItem @key()
    item_as_json = JSON.parse item_as_string
    options.success item_as_json
  
  key: ->
    [@options.namespace, @model.get('id')].join '.'
  
  generateId: ->
    Math.round Math.random()*5000000
