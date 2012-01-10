Wingman = require '../wingman'

module.exports = class extends Wingman.Object
  constructor: (hash) ->
    @dirty_static_property_names = []
    for key, value of hash
      h = {}
      h[key] = value
      @set h
  
  clean: ->
    @dirty_static_property_names.length = 0
  
  dirtyStaticProperties: ->
    @toJSON only: @dirty_static_property_names
  
  setProperty: (property_name, values) ->
    @dirty_static_property_names.push property_name
    super property_name, values
  
  save: ->
    Wingman.request
      type: @saveHTTPMethod()
      url: @saveURL()
      data: @dirtyStaticProperties() # måske overvej at gøre modellen klar over hvilke attributes der er ændret siden load?
      success: @requestSuccess
  
  saveHTTPMethod: ->
    if @persisted()
      'PUT'
    else
      'POST'
  
  requestSuccess: (data) =>
    @set id: data.id if data.id?
  
  persisted: ->
    !!@get('id')
  
  saveURL: ->
    url = @get 'url'
    url += "/#{@get('id')}" if @persisted()
    url