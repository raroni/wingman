WingmanObject = require './shared/object'
Wingman = require '../wingman'
FamilyMember = require './shared/family_member'
Navigator = require './shared/navigator'

module.exports = class extends WingmanObject
  @include FamilyMember
  @include Navigator
  
  constructor: (options) ->
    @parent = options.parent if options?.parent?
    @familize 'Controller', options.children
    @view = options?.view || @findView()
    @ready?()
  
  findView: (path) ->
    @parent.findView(path || @path())
