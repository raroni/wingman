Module = require '../../shared/module'
Elementary = require '../../shared/elementary'

module.exports = class Element extends Module
  @include Elementary
  
  constructor: (@elementData, @scope, @context) ->
    @domElement = Wingman.document.createElement @elementData.tag
    @addToScope()
    @setupStyles() if @elementData.styles
    @setupClasses() if @elementData.classes
    @setupAttributes() if @elementData.attributes
    
    if @elementData.value
      @setupInnerHTML()
    else if @elementData.children
      @setupChildren()
  
  addToScope: ->
    @scope.appendChild @domElement
  
  setupClasses: ->
    for className in @elementData.classes
      @observeClass className if className.isDynamic
      @addClass className.get @context
  
  setupAttributes: ->
    for key, value of @elementData.attributes
      @setAttribute key, value.get(@context)
      @observeAttribute key, value if value.isDynamic
  
  observeAttribute: (key, value) ->
    @context.observe value.get(), (newValue) =>
      @setAttribute key, newValue
  
  observeClass: (className) ->
    @context.observe className.get(), (newClassName, oldClassName) =>
      @removeClass oldClassName
      @addClass newClassName
  
  setupStyles: -> 
    for key, value of @elementData.styles
      @observeStyle key, value if value.isDynamic
      @setStyle key, value.get @context
  
  observeStyle: (key, value) ->
    @context.observe value.get(), (newValue) => @setStyle key, newValue
  
  setupInnerHTML: ->
    @domElement.innerHTML = if @elementData.value.isDynamic
      @context.observe @elementData.value.get(), (newValue) =>
        @domElement.innerHTML = newValue
      @context.get @elementData.value.get()
    else
      @elementData.value.get()
  
  setupChildren: ->
    for child in @elementData.children
      NodeFactory.create child, @domElement, @context

Wingman = require '../../../wingman'
NodeFactory = require '../node_factory'
