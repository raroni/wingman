WingmanObject = require './shared/object'
ChildInstantiator = require './shared/child_instantiator'
ObjectTree = require './object_tree'
Navigator = require './shared/navigator'

module.exports = class extends WingmanObject
  @include ChildInstantiator
  @include Navigator
  
  constructor: (options) ->
    @parent = options.parent if options?.parent?
    new ObjectTree @, 'Controller'
    
    @view = if options?.view?
      options.view 
    else
      @findView()
      
    @ready?()
  
  activate: ->
    @parent.deactivateDescendantsExceptChild @name
    @is_active = true
    @view.activate()
  
  deactivate: ->
    @is_active = false
    @view.deactivate()
  
  findView: (path) ->
    @parent.findView(path || @path())
