Janitor = require 'janitor'
Tree = require '../../lib/wingman/tree'
WingmanObject = require '../../lib/wingman/shared/object'

module.exports = class extends Janitor.TestCase
  'test simple tree': ->
    DummyApp = class
      constructor: ->
        @views = new Tree @, 'View', attach_to: 'tree'
    
    View = class extends WingmanObject
      constructor: ->
        new Tree @, 'View'
    
    DummyApp.UserView = class extends View
    DummyApp.HomeView = class extends View
    DummyApp.BlahController = class extends View
    
    dummy_app = new DummyApp
    
    @assert dummy_app.views.get('user') instanceof DummyApp.UserView
    @assert dummy_app.views.get('home') instanceof DummyApp.HomeView
    @assert !dummy_app.views.get('blah')
    
  'test multi level tree': ->
    DummyApp = class
      constructor: ->
        @views = new Tree @, 'View', attach_to: 'tree'
    
    View = class extends WingmanObject
      constructor: ->
        new Tree @, 'View'
    
    DummyApp.UserView = class extends View
    DummyApp.UserView.NameView = class extends View
    DummyApp.HomeView = class extends View
    
    dummy_app = new DummyApp
    @assert dummy_app.views.get('user.name') instanceof DummyApp.UserView.NameView
