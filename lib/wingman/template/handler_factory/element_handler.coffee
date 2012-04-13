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
    for key, value of @elementData.attributes
      if value.isDynamic
        @observeAttribute key, value
        @setAttribute key, @context.get(value.value)
      else
        @setAttribute key, value.value
  
  observeAttribute: (key, value) ->
    @context.observe value.value, (newValue) =>
      @setAttribute key, newValue
  
  observeClass: (klass) ->
    @context.observe klass.value, (newClassName, oldClassName) =>
      @removeClass oldClassName if oldClassName
      @addClass newClassName if newClassName
  
  setupStyles: -> 
    for key, value of @elementData.styles
      if value.isDynamic
        @observeStyle key, value
        @setStyle key, @context.get(value.value)
      else
        @setStyle key, value.value
  
  observeStyle: (key, value) ->
    @context.observe value.value, (newValue) => @setStyle key, newValue
  
  setupSource: ->
    @domElement.innerHTML = @context.get @elementData.source
    @context.observe @elementData.source, (newValue) =>
      @domElement.innerHTML = newValue
  
  setupChildren: ->
    for child in @elementData.children
      HandlerFactory.create child, @domElement, @context

Wingman = require '../../../wingman'
HandlerFactory = require '../handler_factory'
