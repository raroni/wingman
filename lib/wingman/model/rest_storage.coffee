Wingman = require '../../wingman'

module.exports = class
  constructor: (@model, @options) ->
  
  create: (options = {}) ->
    Wingman.request
      type: 'POST'
      url: @options.url
      data: @model.dirtyStaticProperties()
      error: options.error
      success: (data) =>
        @requestSuccess data
        options.success?()
  
  update: (options = {}) ->
    Wingman.request
      type: 'PUT'
      url: "#{@options.url}/#{@model.get('id')}"
      data: @model.dirtyStaticProperties()
      error: options.error
      success: (data) =>
        @requestSuccess data
        options.success?()
  
  requestSuccess: (data) =>
    @model.set data
