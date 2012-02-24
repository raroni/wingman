exports.create = (@node_data, @scope, @context) ->
  if @node_data.type == 'for'
    new ForBlock @node_data, @scope, @context
  else if @node_data.type == 'child_view'
    new ChildView @node_data, @scope, @context
  else if @node_data.type == 'conditional'
    new Conditional @node_data, @scope, @context
  else
    new Element @node_data, @scope, @context

ForBlock = require './node_factory/for_block'
ChildView = require './node_factory/child_view'
Conditional = require './node_factory/conditional'
Element = require './node_factory/element'
