exports.create = (@nodeData, @scope, @context) ->
  if @nodeData.type == 'for'
    new ForBlock @nodeData, @scope, @context
  else if @nodeData.type == 'childView'
    new ChildView @nodeData, @scope, @context
  else if @nodeData.type == 'conditional'
    new Conditional @nodeData, @scope, @context
  else if @nodeData.type == 'element'
    new Element @nodeData, @scope, @context
  else if @nodeData.type == 'text'
    new TextNode @nodeData, @scope, @context
  else
    throw new Error "Cannot create unknown node type (#{@nodeData.type})!"

ForBlock = require './node_factory/for_block'
ChildView = require './node_factory/child_view'
Conditional = require './node_factory/conditional'
Element = require './node_factory/element'
TextNode = require './node_factory/text_node'
