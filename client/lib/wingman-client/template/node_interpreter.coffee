module.exports = class
  constructor: (@node_data, @scope, @context) ->
    if @node_data.type == 'for'
      @interpretFor()
    else if @node_data.type == 'child_view'
      @interpretChildView()
    else
      @interpretElement()
  
  interpretFor: ->
    new ForBlock @node_data, @scope, @context
  
  interpretChildView: ->
    view = @context.createChildView @node_data.name
    element = view.el
    @scope.appendChild element
  
  interpretElement: ->
    e = new Element @node_data, @scope, @context
    @element = e.dom_element

# By requiring these after module.exports, node can handle the cyclic
# dependency between node_interpreter and node_interpreter/for_child_element
ForBlock = require './node_interpreter/for_block'
Element = require './node_interpreter/element'
