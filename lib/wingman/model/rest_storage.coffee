Wingman = require '../../wingman'

module.exports = class
  constructor: (@options) ->
  
  create: (model, options = {}) ->
    Wingman.request
      type: 'POST'
      url: @options.url
      data: model.dirtyStaticProperties()
      error: options.error
      success: (data) =>
        @requestSuccess model, data
        options.success?()
  
  update: (model, options = {}) ->
    Wingman.request
      type: 'PUT'
      url: "#{@options.url}/#{model.get('id')}"
      data: model.dirtyStaticProperties()
      error: options.error
      success: (data) =>
        @requestSuccess model, data
        options.success?()
  
  requestSuccess: (model, data) =>
    model.set data
