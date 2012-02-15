NodeInterpreter = require '../node_interpreter'

module.exports = class Conditional
  constructor: (@node_data, @scope, @context) ->
    @nodes = []
    @add()
    @context.observe @node_data.source, @update
    @update @context.get(@node_data.source)
  
  add: ->
    for new_node_data in @node_data.children
      node = new NodeInterpreter new_node_data, @scope, @context
      @nodes.push node
  
  remove: ->
    throw new Error 'Not implemented!'
  
  activate: ->
    node.activate() for node in @nodes
    
  deactivate: ->
    node.deactivate() for node in @nodes
  
  update: (current_value) =>
    if current_value
      @activate()
    else
      @deactivate()
