Wingman = require '../wingman'

module.exports = class extends Wingman.Object
  constructor: (hash) ->
    @dirty_static_property_names = []
    @set hash
  
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
      data: @dirtyStaticProperties()
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