Wingman = require '../../wingman-client'

module.exports =
  navigate: (location, options = {}) ->
    Wingman.window.history.pushState options, '', "/#{location}"
    Wingman.Application.instance.updateNavigationOptions options
    Wingman.Application.instance.updatePath()
  
  back: ->
    Wingman.window.history.back()
