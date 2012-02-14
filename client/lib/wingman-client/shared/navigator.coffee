Wingman = require '../../wingman-client'

module.exports =
  navigate: (location) ->
    Wingman.window.history.pushState {}, '', "/#{location}"
    Wingman.Application.instance.updatePath()
  
  back: ->
    Wingman.window.history.back()
