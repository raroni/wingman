module.exports = class Store
  constructor: ->
    @models = []
  
  add: (model) ->
    @models.push model
  
  count: ->
    @models.length
