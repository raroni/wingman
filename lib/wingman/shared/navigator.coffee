Wingman = require '../../wingman'

module.exports =
  navigate: (location, options = {}) ->
    Wingman.window.history.pushState options, '', "/#{location}"
    
    # This is not good enough - it really should be redesigned:
    if Wingman.Application.instance
      Wingman.Application.instance.updateNavigationOptions options
      Wingman.Application.instance.updatePath()
  
  back: (times = 1) ->
    Wingman.window.history.go -times
