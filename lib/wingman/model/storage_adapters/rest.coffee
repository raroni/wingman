Wingman = require '../../../wingman'

module.exports = Wingman.Object.extend
  initialize: (hash) ->
    @url = hash.url
  
  create: (model, options = {}) ->
    Wingman.request
      type: 'POST'
      url: @url
      data: model.dirtyStaticProperties()
      error: options.error
      success: options.success
  
  update: (model, options = {}) ->
    Wingman.request
      type: 'PUT'
      url: "#{@url}/#{model.get('id')}"
      data: model.dirtyStaticProperties()
      error: options.error
      success: options.success
  
  load: (args...) ->
    if args.length == 2
      options = args[1]
      options.url = [@url, args[0]].join '/'
    else
      options = args[0]
      options.url = @url
    
    options.type = 'GET'
    Wingman.request options
  
  delete: (id) ->
    Wingman.request
      url: [@url, id].join('/')
      type: 'DELETE'
