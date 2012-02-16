NodeInterpreter = require '../node_interpreter'

module.exports = class Conditional
  constructor: (@node_data, @scope, @context) ->
    @nodes =
      true: []
      false: []
    
    @add()
    @context.observe @node_data.source, @update
    @update @context.get(@node_data.source)
  
  add: ->
    for new_node_data in @node_data.true_children
      node = new NodeInterpreter new_node_data, @scope, @context
      @nodes.true.push node
    
    if @node_data.false_children
      for new_node_data in @node_data.false_children
        node = new NodeInterpreter new_node_data, @scope, @context
        @nodes.false.push node
  
  remove: ->
    throw new Error 'Not implemented!'
  
  activate: ->
    node.activate() for node in @nodes.true
    node.deactivate() for node in @nodes.false
    
  deactivate: ->
    node.deactivate() for node in @nodes.true
    node.activate() for node in @nodes.false
  
  update: (current_value) =>
    if current_value
      @activate()
    else
      @deactivate()
