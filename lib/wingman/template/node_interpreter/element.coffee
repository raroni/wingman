module.exports = class
  constructor: (@element_data, @scope, @context) ->
    @dom_element = Template.document.createElement @element_data.tag
    @addToScope()
    @setupStyles() if @element_data.styles

    if @element_data.value
      @setupInnerHTML()
    else if @element_data.children
      @setupChildren()

  addToScope: ->
    if @scope.appendChild
      @scope.appendChild @dom_element
    else
      @scope.push @dom_element

  setupStyles: -> 
    for key, value of @element_data.styles
      @dom_element.style[key] = if value.is_dynamic
        @context.observe value.get(), (new_value) =>
          @dom_element.style[key] = new_value
        @context.get value.get()
      else
        value.get()
  
  setupInnerHTML: ->
    @dom_element.innerHTML = if @element_data.value.is_dynamic
      @context.observe @element_data.value.get(), (new_value) =>
        @dom_element.innerHTML = new_value
      @context.get @element_data.value.get()
    else
      @element_data.value.get()
  
  setupChildren: ->
    for child in @element_data.children
      new NodeInterpreter child, @dom_element, @context, @document

Template = require '../../template'
NodeInterpreter = require '../node_interpreter'
