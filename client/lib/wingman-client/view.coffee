Wingman = require '../wingman-client'
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
    super()
    @set parent: options.parent if options?.parent?
    @set session: options.session if options?.session?
    @set shared: options.shared if options?.shared?
    @el = @dom_element = options?.el || Wingman.document.createElement 'div'
    @render() if options?.render
  
  render: ->
    template = Wingman.Template.compile @templateSource()
    template @el, @
    @addClass @pathName()
    @setupListeners()
    @setupActiveListener() if @isActive
    @ready?()
  
  createSubView: (view_name) ->
    class_name = Fleck.camelize "#{view_name}_view", true
    klass = @constructor[class_name]
    view = new klass parent: @, session: @session, shared: @shared
    view.bind 'descendantCreated', (view) => @trigger 'descendantCreated', view
    @trigger 'descendantCreated', view
    view.render()
    view
  
  templateSource: ->
    template_source = @constructor.template_sources[@path()]
    throw new Error "Template '#{@path()}' not found." unless template_source
    template_source
  
  setupListeners: ->
    @el.addEventListener 'click', (e) => @click(e) if @click
    @setupEvents() if @events
  
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
  
  pathName: ->
    Fleck.underscore @constructor.name.replace(/([A-Z])/g, ' $1').substring(1).split(' ').slice(0, -1).join('')
  
  pathKeys: ->
    return [] if @isRoot()
    path_keys = [@pathName()]
    path_keys = @get('parent').pathKeys().concat path_keys if @get('parent')?.pathKeys?
    path_keys
  
  isRoot: ->
    @get('parent') instanceof Wingman.Application
  
  path: ->
    if @get('parent') instanceof Wingman.Application
      'root'
    else
      @pathKeys().join '.'
