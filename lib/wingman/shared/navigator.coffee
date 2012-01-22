Wingman = require '../../wingman'

module.exports =
  navigate: (location) ->
    Wingman.window.history.pushState {}, '', location
    Wingman.App.instance.checkURL()
