Wingman = require '../wingman'
WingmanObject = require './shared/object'
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
]

module.exports = class extends WingmanObject
  @include Elementary
  
  @parseEvents: (eventsHash) ->
    (@parseEvent(key, trigger) for key, trigger of eventsHash)
  
  @parseEvent: (key, trigger) ->
    type = key.split(' ')[0]
    {
      selector: key.substring(type.length + 1)
      type
      trigger
    }
  
  constructor: (options) ->
    super()
    @set parent: options.parent if options?.parent?
    @set app: options.app if options?.app?
    @el = @domElement = options?.el || Wingman.document.createElement(@tag || 'div')
    @set children: []
    @render() if options?.render
  
  name: ->
    withoutView = @constructor.name.replace ///View$///, ''
    Fleck.camelize Fleck.underscore(withoutView)
  
  render: ->
    templateSource = @get 'templateSource'
    if templateSource
      template = Wingman.Template.compile templateSource
      template @el, @
    
    @addClass @pathName()
    @setupListeners()
    @setupStyles()
    @ready?()
  
  createChildView: (viewName, options) ->
    className = Fleck.camelize(Fleck.underscore(viewName), true) + 'View'
    klass = @constructor[className]
    
    view = new klass parent: @, app: @get('app')
    view.set options.properties if options?.properties
    
    @get('children').push view
    view.bind 'remove', => @get('children').remove view
    
    view.bind 'descendantCreated', (view) => @trigger 'descendantCreated', view
    @trigger 'descendantCreated', view
    
    view.render() if options?.render
    
    view
  
  templateSource: ->
    name = @get 'templateName'
    templateSource = @constructor.templateSources[name]
    throw new Error "Template '#{name}' not found." unless templateSource
    templateSource
  
  templateName: ->
    @path()
  
  setupListeners: ->
    @el.addEventListener 'click', (e) => @click(e) if @click
    @setupEvents() if @events
  
  setupEvents: ->
    @setupEvent event for event in @constructor.parseEvents(@events)
  
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
  
  pathName: ->
    Fleck.underscore @constructor.name.replace(/([A-Z])/g, ' $1').substring(1).split(' ').slice(0, -1).join('')
  
  append: (view) ->
    @el.appendChild view.el
  
  pathKeys: ->
    return [] if @isRoot()
    pathKeys = [@pathName()]
    pathKeys = @get('parent').pathKeys().concat pathKeys if @get('parent')?.pathKeys?
    pathKeys
  
  isRoot: ->
    @get('parent') instanceof Wingman.Application
  
  path: ->
    if @get('parent') instanceof Wingman.Application
      'root'
    else
      @pathKeys().join '.'
  
  remove: ->
    Elementary.remove.call @ if @el.parentNode
    @trigger 'remove'
  
  setupStyles: ->
    for name, property of @
      @setupStyle name if name in STYLE_NAMES
  
  setupStyle: (name) ->
    @setStyle name, @get(name)
    @observe name, (newValue) => @setStyle name, newValue
