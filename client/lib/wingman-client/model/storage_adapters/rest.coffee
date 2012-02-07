Wingman = require '../../../wingman-client'

module.exports = class
  constructor: (@options) ->
  
  create: (model, options = {}) ->
    Wingman.request
      type: 'POST'
      url: @options.url
      data: model.dirtyStaticProperties()
      error: options.error
      success: options.success
  
  update: (model, options = {}) ->
    Wingman.request
      type: 'PUT'
      url: "#{@options.url}/#{model.get('id')}"
      data: model.dirtyStaticProperties()
      error: options.error
      success: options.success
  
  load: (args...) ->
    if args.length == 2
      options = args[1]
      options.url = [@options.url, args[0]].join '/'
    else
      options = args[0]
      options.url = @options.url
    
    options.type = 'GET'
    Wingman.request options
  
  delete: (id) ->
    Wingman.request
      url: [@options.url, id].join('/')
      type: 'DELETE'
