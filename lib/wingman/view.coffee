Wingman = require '../wingman'
Elementary = require './shared/elementary'
Fleck = require 'fleck'

STYLE_NAMES = [
  'backgroundImage'
  'backgroundColor'
  'backgroundPosition'
  'left'
  'right'
  'top'
  'bottom'
  'width'
  'height'
]

Prototype =
  children: null
  
  initialize: (options) ->
    @parent = options.parent if options?.parent
    @el = options.el if options?.el
    @state = options.state if options?.state
    @childClasses = options.childClasses if options?.childClasses
    
    @el ||= Wingman.document.createElement(@tag || 'div')
    @children = []
    @_super()
  
  name: ->
    withoutView = @constructor.name.replace ///View$///, ''
    Fleck.camelize Fleck.underscore(withoutView)
  
  render: ->
    if @templateSource
      template = Wingman.Template.compile @templateSource
      template @el, @
    
    @addClass @className
    
    @setupListeners()
    @setupStyles()
    @ready?()
  
  getChildClasses: ->
    @constructor
  
  createChild: (name, options) ->
    className = Fleck.camelize(Fleck.underscore(name), true) + 'View'
    Child = @get('childClasses')[className]
    
    child = new Child parent: @, state: @get('state')
    child.set options.properties if options?.properties
    
    @get('children').push child
    child.bind 'remove', => @children.remove child
    
    child.bind 'descendantCreated', (child) => @trigger 'descendantCreated', child
    @trigger 'descendantCreated', child
    
    child.render() if options?.render
    child
  
  getTemplateSource: ->
    templateSource = View.templateSources[@templateName]
    throw new Error "Template '#{@templateName}' not found." unless templateSource
    templateSource
  
  setupListeners: ->
    @el.addEventListener 'click', (e) => @click(e) if @click
    @setupEvents() if @events
  
  setupEvents: ->
    @setupEvent event for event in View.parseEvents(@events)
  
  triggerWithCustomArguments: (trigger) ->
    args = [trigger]
    argumentsMethodName = Fleck.camelize(trigger) + "Arguments"
    customArguments = @[argumentsMethodName]?()
    args.push.apply args, customArguments if customArguments
    @trigger.apply @, args
  
  setupEvent: (event) ->
    @el.addEventListener event.type, (e) =>
      for elm in Array.prototype.slice.call(@el.querySelectorAll(event.selector), 0)
        current = e.target
        while current != @el && !match
          match = elm == current
          current = current.parentNode
        if match
          @triggerWithCustomArguments event.trigger
          e.preventDefault()
  
  append: (view) ->
    @el.appendChild view.el
  
  getIsRoot: ->
    @get('parent') instanceof Wingman.Application
  
  path: ->
    return [] if @isRoot
    @parent.path().concat @constructor
  
  remove: ->
    Elementary.remove.call @ if @el.parentNode
    @trigger 'remove'
  
  setupStyles: ->
    for name, property of @
      @setupStyle name if name in STYLE_NAMES
  
  setupStyle: (name) ->
    @setStyle name, @get(name)
    @observe name, (newValue) => @setStyle name, newValue
  
  createSubContext: ->
    context = @_super()
    context.bind 'descendantCreated', (child) => @trigger 'descendantCreated', child
    context

ClassProperties =
  parseEvents: (eventsHash) ->
    (@parseEvent(key, trigger) for key, trigger of eventsHash)
  
  parseEvent: (key, trigger) ->
    type = key.split(' ')[0]
    {
      selector: key.substring(type.length + 1)
      type
      trigger
    }

View = Wingman.Object.extend null, ClassProperties
View.prototype.include Elementary, Prototype

module.exports = View
