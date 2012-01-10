Wingman = require '../wingman'

exports.request = (args...) ->
  if Wingman.App.instance?.host?
    args[0].url = "http://#{Wingman.App.instance.host}/#{args[0].url}"
  
  @realRequest args...

exports.realRequest = jQuery.ajax if jQuery?
