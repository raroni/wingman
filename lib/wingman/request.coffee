Wingman = require '../wingman'

request = (args...) ->
  if Wingman.Application.instance?.host?
    args[0].url = ['http://', Wingman.Application.instance.host, args[0].url].join ''
  
  args[0].dataType ||= 'json'
  
  request.realRequest args...

request.realRequest = jQuery.ajax if jQuery?

module.exports = request
