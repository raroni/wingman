Wingman = require '../wingman'
WingmanObject = require './shared/object'
Elementary = require './shared/elementary'
FamilyMember = require './shared/family_member'
Fleck = require 'fleck'

module.exports = class extends WingmanObject
  @include Elementary
  @include FamilyMember
  
  @parseEvents: (events_hash) ->
    (@parseEvent(key, trigger) for key, trigger of events_hash)
  
  @parseEvent: (key, trigger) ->
    type = key.split(' ')[0]
    {
      selector: key.substring(type.length + 1)
      type
      trigger
    }
  
  constructor: (options) ->
    @parent = options.parent if options?.parent?
    @el = @dom_element = options?.el || Wingman.document.createElement 'div'
    @createChildren 'View', child_source: options?.child_source
    template = Wingman.Template.compile @templateSource()
    template @el, @
    @addClass @constructor._name
    @setupEvents() if @events?
    @setupActiveListener()
  
  templateSource: ->
    template_source = @constructor.template_sources[@path()]
    throw new Error "Template '#{@path()}' not found." unless template_source
    template_source

  setupEvents: ->
    @setupEvent event for event in @constructor.parseEvents(@events)
  
  triggerWithCustomArguments: (trigger) ->
    args = [trigger]
    arguments_method_name = Fleck.camelize(trigger) + "Arguments"
    custom_arguments = @[arguments_method_name]?()
    args.push.apply args, custom_arguments if custom_arguments
    @trigger.apply @, args
  
  setupEvent: (event) ->
    @el.addEventListener event.type, (e) =>
      for elm in Array.prototype.slice.call(@el.querySelectorAll(event.selector), 0)
        if elm == e.target
          @triggerWithCustomArguments event.trigger
          e.preventDefault()
  
  setupActiveListener: ->
    @observe 'isActive', @checkIsActive
    @checkIsActive()
  
  checkIsActive: =>
    if @get 'isActive'
      @setStyle 'display', ''
    else
      @setStyle 'display', 'none'
  
  activate: ->
    @is_active = true
    @addClass 'active'

  deactivate: ->
    @is_active = false
    @removeClass 'active'
