WingmanObject = require '../../shared/object'
Elementary = require '../../shared/elementary'

ElementHandler = WingmanObject.extend
  initialize: ->
    @setupDomElement()
    @setupStyles() if @options.styles
    @setupClasses() if @options.classes
    @setupAttributes() if @options.attributes
    
    if @options.source
      @setupSource()
    else if @options.children
      @setupChildren()
  
  setupDomElement: ->
    @el = if @options.el
      @options.el
    else
      element = Wingman.document.createElement @options.tag
      @options.scope.appendChild element
      element
  
  setupClasses: ->
    for klass in @options.classes
      if klass.isDynamic
        @observeClass klass
        @addClass klassValue if klassValue = @context[klass.value]
      else
        @addClass klass.value
  
  setupAttributes: ->
    for key, attribute of @options.attributes
      if attribute.isDynamic
        @observeAttribute key, attribute
        @setAttribute key, @context[attribute.value]
      else
        @setAttribute key, attribute.value
  
  observeAttribute: (key, attribute) ->
    @context.observe attribute.value, (newValue) =>
      @setAttribute key, newValue
  
  observeClass: (klass) ->
    @context.observe klass.value, (newClassName, oldClassName) =>
      @removeClass oldClassName if oldClassName
      @addClass newClassName if newClassName
  
  setupStyles: -> 
    for key, style of @options.styles
      if style.isDynamic
        @observeStyle key, style
        @setStyle key, @context[style.value]
      else
        @setStyle key, style.value
  
  observeStyle: (key, style) ->
    @context.observe style.value, (newValue) => @setStyle key, newValue
  
  setupSource: ->
    @el.innerHTML = @context.get @options.source
    @context.observe @options.source, (newValue) =>
      @el.innerHTML = newValue
  
  setupChildren: ->
    for child in @options.children
      options = { scope: @el }
      options[key] = value for key, value of child
      HandlerFactory.create options, @context

ElementHandler.include Elementary

module.exports = ElementHandler

Wingman = require '../../../wingman'
HandlerFactory = require '../handler_factory'
