NodeFactory = require '../node_factory'

module.exports = class Conditional
  constructor: (@nodeData, @scope, @context) ->
    @nodes = []
    @context.observe @nodeData.source, @update
    @update @context.get(@nodeData.source)
  
  add: (currentValue) ->
    if currentValue
      for newNodeData in @nodeData.trueChildren
        node = NodeFactory.create newNodeData, @scope, @context
        @nodes.push node
    else if @nodeData.falseChildren
      for newNodeData in @nodeData.falseChildren
        node = NodeFactory.create newNodeData, @scope, @context
        @nodes.push node
  
  remove: ->
    node.remove() while node = @nodes.shift()
  
  update: (currentValue) =>
    @remove()
    @add currentValue
