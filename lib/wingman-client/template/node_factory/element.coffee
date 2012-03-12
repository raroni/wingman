Module = require '../../shared/module'
Elementary = require '../../shared/elementary'

module.exports = class Element extends Module
  @include Elementary
  
  constructor: (@element_data, @scope, @context) ->
    @dom_element = Wingman.document.createElement @element_data.tag
    @addToScope()
    @setupStyles() if @element_data.styles
    @setupClasses() if @element_data.classes
    @setupAttributes() if @element_data.attributes
    
    if @element_data.value
      @setupInnerHTML()
    else if @element_data.children
      @setupChildren()
  
  addToScope: ->
    @scope.appendChild @dom_element
  
  setupClasses: ->
    for class_name in @element_data.classes
      @observeClass class_name if class_name.is_dynamic
      @addClass class_name.get @context
  
  setupAttributes: ->
    for key, value of @element_data.attributes
      @setAttribute key, value.get(@context)
      @observeAttribute key, value if value.is_dynamic
  
  observeAttribute: (key, value) ->
    @context.observe value.get(), (new_value) =>
      @setAttribute key, new_value
  
  observeClass: (class_name) ->
    @context.observe class_name.get(), (new_class_name, old_class_name) =>
      @removeClass old_class_name
      @addClass new_class_name
  
  setupStyles: -> 
    for key, value of @element_data.styles
      @observeStyle key, value if value.is_dynamic
      @setStyle key, value.get @context
  
  observeStyle: (key, value) ->
    @context.observe value.get(), (new_value) => @setStyle key, new_value
  
  setupInnerHTML: ->
    @dom_element.innerHTML = if @element_data.value.is_dynamic
      @context.observe @element_data.value.get(), (new_value) =>
        @dom_element.innerHTML = new_value
      @context.get @element_data.value.get()
    else
      @element_data.value.get()
  
  setupChildren: ->
    for child in @element_data.children
      NodeFactory.create child, @dom_element, @context

Wingman = require '../../../wingman-client'
NodeFactory = require '../node_factory'
