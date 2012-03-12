WingmanObject = require './shared/object'
Wingman = require '../wingman-client'
Navigator = require './shared/navigator'

module.exports = class extends WingmanObject
  @include Navigator
  
  constructor: (view) ->
    super()
    @set view: view
    @set session: view.session
    @set shared: view.shared
    @ready?()
