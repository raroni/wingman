WingmanObject = require './shared/object'
Wingman = require '../wingman'
Navigator = require './shared/navigator'

module.exports = class extends WingmanObject
  @include Navigator
  
  constructor: (view) ->
    super()
    @set view: view
    @set app: view.app
    @ready?()
