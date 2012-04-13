Module = require '../../shared/module'
Elementary = require '../../shared/elementary'

module.exports = class ElementHandler extends Module
  @include Elementary
  
  constructor: (@options, @context) ->
    @setupDomElement()
    @setupStyles() if @options.styles
    @setupClasses() if @options.classes
    @setupAttributes() if @options.attributes
    
    if @options.source
      @setupSource()
    else if @options.children
      @setupChildren()
  
  setupDomElement: ->
    @domElement = if @options.el
      @options.el
    else
      element = Wingman.document.createElement @options.tag
      @options.scope.appendChild element
      element
  
  setupClasses: ->
    for klass in @options.classes
      if klass.isDynamic
        @observeClass klass
        @addClass klassValue if klassValue = @context.get(klass.value)
      else
        @addClass klass.value
  
  setupAttributes: ->
    for key, attribute of @options.attributes
      if attribute.isDynamic
        @observeAttribute key, attribute
        @setAttribute key, @context.get(attribute.value)
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
        @setStyle key, @context.get(style.value)
      else
        @setStyle key, style.value
  
  observeStyle: (key, style) ->
    @context.observe style.value, (newValue) => @setStyle key, newValue
  
  setupSource: ->
    @domElement.innerHTML = @context.get @options.source
    @context.observe @options.source, (newValue) =>
      @domElement.innerHTML = newValue
  
  setupChildren: ->
    for child in @options.children
      options = { scope: @domElement }
      options[key] = value for key, value of child
      HandlerFactory.create options, @context

Wingman = require '../../../wingman'
HandlerFactory = require '../handler_factory'
