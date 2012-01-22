Wingman = require '../wingman'
WingmanObject = require './shared/object'
Elementary = require './shared/elementary'
Fleck = require 'fleck'

module.exports = class extends WingmanObject
  @include Elementary
  
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
    @el = @dom_element = Wingman.document.createElement 'div'
    @template_path = options.template_path if options.template_path
    options.parent_el.appendChild @el
   
    template = Wingman.Template.compile @templateSource()
    elements = template @
    @el.appendChild element for element in elements
    @setupEvents() if @events?
  
  templateSource: ->
    @constructor.template_sources[@template_path]

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
  
  activate: ->
    @is_active = true
    @addClass 'active'

  deactivate: ->
    @is_active = false
    @removeClass 'active'
