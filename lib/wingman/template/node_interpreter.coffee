module.exports = class
  constructor: (@node_data, @scope, @context) ->
    if @node_data.type == 'for'
      @interpretFor()
    else
      @interpretElement()
  
  interpretFor: ->
    for new_node_data in @node_data.children
      new ForChildElement new_node_data, @scope, @context, @node_data.source

  interpretElement: ->
    e = new Element @node_data, @scope, @context
    @element = e.dom_element

# By requiring these after module.exports, node can handle the cyclic
# dependency between node_interpreter and node_interpreter/for_child_element
ForChildElement = require './node_interpreter/for_child_element'
Element = require './node_interpreter/element'
