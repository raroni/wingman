NodeFactory = require '../node_factory'

module.exports = class Conditional
  constructor: (@node_data, @scope, @context) ->
    @nodes = []
    @context.observe @node_data.source, @update
    @update @context.get(@node_data.source)
  
  add: (current_value) ->
    if current_value
      for new_node_data in @node_data.true_children
        node = NodeFactory.create new_node_data, @scope, @context
        @nodes.push node
    else if @node_data.false_children
      for new_node_data in @node_data.false_children
        node = NodeFactory.create new_node_data, @scope, @context
        @nodes.push node
  
  remove: ->
    node.remove() while node = @nodes.shift()
  
  update: (current_value) =>
    @remove()
    @add current_value
