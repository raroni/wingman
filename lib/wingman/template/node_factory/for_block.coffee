WingmanObject = require '../../shared/object'
Fleck = require 'fleck'
NodeFactory = require '../node_factory'

module.exports = class ForBlock
  constructor: (@nodeData, @scope, @context) ->
    @nodes = {}
    @addAll() if @source()
    @context.observe @nodeData.source, @rebuild
    @context.observe @nodeData.source, 'add', @add
    @context.observe @nodeData.source, 'remove', @remove
  
  add: (value) =>
    @nodes[value] = []
    
    newContext = new WingmanObject
    if @context.createChildView
      # The line below would be prettier, but Function#bind is not supported on iOS5.
      # newContext.createChildView = @context.createChildView.bind @context
      newContext.createChildView = (name) => @context.createChildView.call @context, name
    key = Fleck.singularize @nodeData.source.split('.').pop()
    hash = {}
    hash[key] = value
    newContext.set hash
    
    for newNodeData in @nodeData.children
      node = NodeFactory.create newNodeData, @scope, newContext
      @nodes[value].push node
  
  remove: (value) =>
    while @nodes[value].length
      node = @nodes[value].pop()
      node.remove()
    delete @nodes[value]
  
  source: ->
    @context.get @nodeData.source
  
  addAll: ->
    @source().forEach (value) => @add value
  
  removeAll: ->
    @remove value for value, element of @nodes
  
  rebuild: =>
    @removeAll()
    @addAll() if @source()
