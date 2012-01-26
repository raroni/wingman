Wingman = require '../../wingman'

module.exports =
  navigate: (location) ->
    Wingman.window.history.pushState {}, '', "/#{location}"
    Wingman.Application.instance.updatePath()
