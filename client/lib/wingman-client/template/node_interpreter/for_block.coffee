WingmanObject = require '../../shared/object'
Fleck = require 'fleck'
NodeInterpreter = require '../node_interpreter'

module.exports = class ForBlock
  constructor: (@node_data, @scope, @context) ->
    @nodes = {}
    @addAll() if @source()
    @context.observe @node_data.source, @rebuild
    @context.observe @node_data.source, 'add', @add
    @context.observe @node_data.source, 'remove', @remove
  
  add: (value) =>
    @nodes[value] = []
    
    for new_node_data in @node_data.children
      new_context = new WingmanObject
      key = Fleck.singularize @node_data.source.split('.').pop()
      hash = {}
      hash[key] = value
      new_context.set hash
      node = new NodeInterpreter new_node_data, @scope, new_context
      @nodes[value].push node
  
  remove: (value) =>
    while @nodes[value].length
      node = @nodes[value].pop()
      node.remove()
    delete @nodes[value]
  
  source: ->
    @context.get @node_data.source
  
  addAll: ->
    @source().forEach (value) => @add value
  
  removeAll: ->
    @remove value for value, element of @nodes
  
  rebuild: =>
    @removeAll()
    @addAll() if @source()
