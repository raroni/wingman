Janitor = require 'janitor'
ObjectTree = require '../../lib/wingman/object_tree'
WingmanObject = require '../../lib/wingman/shared/object'

module.exports = class extends Janitor.TestCase
  'test simple tree': ->
    DummyApp = class
      constructor: ->
        @views = new ObjectTree @, 'View', attach_to: 'tree'
    
    View = class extends WingmanObject
      constructor: (options) ->
        new ObjectTree @, 'View'
        @parent = options.parent
    
    DummyApp.UserView = class extends View
    DummyApp.HomeView = class extends View
    DummyApp.BlahController = class extends View
    
    dummy_app = new DummyApp
    
    @assert dummy_app.views.get('user') instanceof DummyApp.UserView
    @assert dummy_app.views.get('home') instanceof DummyApp.HomeView
    @assertEqual dummy_app, dummy_app.views.get('home').parent
    @assert !dummy_app.views.get('blah')
    
  'test multi level tree': ->
    DummyApp = class
      constructor: ->
        @views = new ObjectTree @, 'View', attach_to: 'tree'
    
    View = class extends WingmanObject
      constructor: (options) ->
        new ObjectTree @, 'View'
        @parent = options.parent
    
    DummyApp.UserView = class extends View
    DummyApp.UserView.NameView = class extends View
    DummyApp.HomeView = class extends View
    
    dummy_app = new DummyApp
    name_view = dummy_app.views.get('user.name')
    @assert name_view instanceof DummyApp.UserView.NameView
    @assert name_view.parent instanceof DummyApp.UserView
