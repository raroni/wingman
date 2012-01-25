Module = require '../../shared/module'
Elementary = require '../../shared/elementary'

module.exports = class extends Module
  @include Elementary
  
  constructor: (@element_data, @scope, @context) ->
    @dom_element = Wingman.document.createElement @element_data.tag
    @addToScope()
    @setupStyles() if @element_data.styles
    @setupClasses() if @element_data.classes
  
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
      new NodeInterpreter child, @dom_element, @context

Wingman = require '../../../wingman'
NodeInterpreter = require '../node_interpreter'
