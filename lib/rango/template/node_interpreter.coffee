RangoObject = require '../object'
Fleck = require 'fleck'

module.exports = class
  @document: document if document?

  constructor: (@node_data, @scope, @context) ->
    if @node_data.type == 'for'
      for new_node_data in @node_data.children
        added_elements = {}

        add_x = (value) =>
          new_context = new RangoObject
          key = Fleck.singularize @node_data.source
          hash = {}
          hash[key] = value
          new_context.set hash
          element = new @constructor(new_node_data, @scope, new_context).element
          added_elements[value] = element

        remove_x = (value) ->
          added_elements[value].parentNode.removeChild added_elements[value]
          delete added_elements[value]
        
        add_all = =>
          for value in @context.get(@node_data.source)
            add_x value

        add_all()
        
        @context.observe @node_data.source, ->
          remove_x value for value, element of added_elements
          add_all()

        @context.observe @node_data.source, 'add', add_x
        @context.observe @node_data.source, 'remove', remove_x
    else
      element = @constructor.document.createElement @node_data.tag

      if @scope.appendChild
        @scope.appendChild element
      else
        @scope.push element
      
      if @node_data.styles
        for key, value of @node_data.styles
          element.style[key] = value.get()

      if @node_data.value
        element.innerHTML = if @node_data.value.is_dynamic
          @context.observe @node_data.value.get(), (new_value) ->
            element.innerHTML = new_value
          @context.get @node_data.value.get()
        else
          @node_data.value.get()
      else if @node_data.children
        for child in @node_data.children
          new @constructor child, element, @context
     @element = element
