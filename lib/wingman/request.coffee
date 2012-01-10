Wingman = require '../wingman'

request = (args...) ->
  if Wingman.App.instance?.host?
    args[0].url = ['http://', Wingman.App.instance.host, args[0].url].join ''
  
  args[0].dataType ||= 'json'
  
  request.realRequest args...

request.realRequest = jQuery.ajax if jQuery?

module.exports = request
