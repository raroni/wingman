WingmanObject = require './shared/object'
Wingman = require '../wingman-client'
FamilyMember = require './shared/family_member'
Navigator = require './shared/navigator'

module.exports = class extends WingmanObject
  @include FamilyMember
  @include Navigator
  
  constructor: (options) ->
    @set parent: options.parent if options?.parent?
    @familize 'controller', options.children
    @view = options?.view || @findView()
    @ready?()
  
  findView: (path) ->
    path ||= @path().replace ///controller///g, 'view'
    @get('parent').findView path
