Module = require '../../shared/module'
Elementary = require '../../shared/elementary'

module.exports = class ElementHandler extends Module
  @include Elementary
  
  constructor: (@elementData, @scope, @context) ->
    @domElement = Wingman.document.createElement @elementData.tag
    @addToScope()
    @setupStyles() if @elementData.styles
    @setupClasses() if @elementData.classes
    @setupAttributes() if @elementData.attributes
    
    if @elementData.source
      @setupSource()
    else if @elementData.children
      @setupChildren()
  
  addToScope: ->
    @scope.appendChild @domElement
  
  setupClasses: ->
    for klass in @elementData.classes
      if klass.isDynamic
        @observeClass klass
        @addClass klassValue if klassValue = @context.get(klass.value)
      else
        @addClass klass.value
  
  setupAttributes: ->
    for key, attribute of @elementData.attributes
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
    for key, style of @elementData.styles
      if style.isDynamic
        @observeStyle key, style
        @setStyle key, @context.get(style.value)
      else
        @setStyle key, style.value
  
  observeStyle: (key, style) ->
    @context.observe style.value, (newValue) => @setStyle key, newValue
  
  setupSource: ->
    @domElement.innerHTML = @context.get @elementData.source
    @context.observe @elementData.source, (newValue) =>
      @domElement.innerHTML = newValue
  
  setupChildren: ->
    for child in @elementData.children
      HandlerFactory.create child, @domElement, @context

Wingman = require '../../../wingman'
HandlerFactory = require '../handler_factory'
