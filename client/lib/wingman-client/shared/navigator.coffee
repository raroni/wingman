Wingman = require '../../wingman-client'

module.exports =
  navigate: (location, options = {}) ->
    Wingman.window.history.pushState options, '', "/#{location}"
    Wingman.Application.instance.updateNavigationOptions options
    Wingman.Application.instance.updatePath()
  
  back: (times = 1) ->
    Wingman.window.history.back times
