exports.create = (@nodeData, @scope, @context) ->
  if @nodeData.type == 'for'
    new ForBlock @nodeData, @scope, @context
  else if @nodeData.type == 'childView'
    new ChildView @nodeData, @scope, @context
  else if @nodeData.type == 'conditional'
    new Conditional @nodeData, @scope, @context
  else
    new Element @nodeData, @scope, @context

ForBlock = require './node_factory/for_block'
ChildView = require './node_factory/child_view'
Conditional = require './node_factory/conditional'
Element = require './node_factory/element'
