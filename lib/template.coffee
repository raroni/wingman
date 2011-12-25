Parser = require './template/parser'
RangoObject = require './object'
Fleck = require 'fleck'

unless window?
  jsdom = require('jsdom').jsdom
  document = jsdom()

module.exports = class
  @compile = (source) ->
    template = new @ source
    (context) ->
      template.evaluate context
  
  constructor: (source) ->
    @tree = Parser.parse source

  evaluate: (context) ->
    @elements = []
    @handleNode(node_data, context) for node_data in @tree.children
    @elements
  
  handleNode: (node_data, context, scope) ->
    if node_data.type == 'for'
      for new_node_data in node_data.children

        # add_x should be renamed ... entire handleNode should probably be refactored!

        added_elements = {}

        add_x = (value) =>
          new_context = new RangoObject
          key = Fleck.singularize node_data.source
          hash = {}
          hash[key] = value
          new_context.set hash
          element = @handleNode new_node_data, new_context, scope
          added_elements[value] = element

        remove_x = (value) ->
          added_elements[value].parentNode.removeChild added_elements[value]
          delete added_elements[value]
        
        add_all = ->
          for value in context.get(node_data.source)
            add_x value

        add_all()
        
        context.observe node_data.source, ->
          remove_x value for value, element of added_elements
          add_all()

        context.observe node_data.source, 'add', add_x
        context.observe node_data.source, 'remove', remove_x

    else
      element = document.createElement node_data.tag
      
      if scope
        scope.appendChild element
      else
        @elements.push element
      
      if node_data.value
        element.innerHTML = if node_data.value.is_dynamic
          context.observe node_data.value.get(), (new_value) ->
            element.innerHTML = new_value
          context.get node_data.value.get()
        else
          node_data.value.get()
      else if node_data.children
        for child in node_data.children
          @handleNode child, context, element
      element
