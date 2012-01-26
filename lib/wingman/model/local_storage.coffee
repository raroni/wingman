Wingman = require '../../wingman'

module.exports = class
  auto_save: true
  
  constructor: (@model, @options) ->
  
  create: (options) ->
    @model.set id: @generateId()
    Wingman.localStorage.setItem @key(), JSON.stringify(@model.toJSON())
    options?.success?()
    
  update: (options) ->
    Wingman.localStorage.setItem @key(), JSON.stringify(@model.toJSON())
    options?.success?()
  
  load: ->
    item_as_string = Wingman.localStorage.getItem @key()
    item_as_json = JSON.parse item_as_string
    @model.set item_as_json
  
  key: ->
    [@options.namespace, @model.get('id')].join '.'
  
  generateId: ->
    Math.round Math.random()*5000000
