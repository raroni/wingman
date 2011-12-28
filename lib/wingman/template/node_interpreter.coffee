RangoObject = require '../object'
ForChildElement = require './node_interpreter/for_child_element'
Element = require './node_interpreter/element'

module.exports = class
  constructor: (@node_data, @scope, @context, @document) ->
    if @node_data.type == 'for'
      @interpretFor()
    else
      @interpretElement()
  
  interpretFor: ->
    for new_node_data in @node_data.children
      # Had to send @constructor because I could not require NodeInterpreter from within ForChildElement.
      # Perhaps the requirement dependency then would be cyclic?
      # Should be cleaned up at some point.
      new ForChildElement new_node_data, @scope, @context, @node_data.source, @constructor, @document

  interpretElement: ->
    e = new Element @node_data, @scope, @context, @constructor, @document
    @element = e.dom_element
