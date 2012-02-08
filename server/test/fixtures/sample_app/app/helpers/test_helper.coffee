SampleApp = require 'application'

SampleApp.AuthHelper =
  included: (base) ->
    base.propertyDependencies loggedIn: 'shared.current_club'
  
  loggedIn: ->
    !!@get('shared.current_club')
