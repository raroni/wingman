module.exports = class
  constructor: (@node_data, @scope, @context) ->
    @node = if @node_data.type == 'for'
      new ForBlock @node_data, @scope, @context
    else if @node_data.type == 'child_view'
      new ChildView @node_data, @scope, @context
    else
      new Element @node_data, @scope, @context
  
  remove: ->
    @node.remove()
  
# By requiring these after module.exports, node can handle the cyclic
# dependency between node_interpreter and node_interpreter/for_child_element
ForBlock = require './node_interpreter/for_block'
ChildView = require './node_interpreter/child_view'
Element = require './node_interpreter/element'
