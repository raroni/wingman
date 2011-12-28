RangoObject = require '../../object'
Fleck = require 'fleck'

module.exports = class
  constructor: (@element_data, @scope, @context, @source_path, @NodeInterpreter, @document) ->
    @elements = {}
    @addAll()
    @context.observe @source_path, @rebuild
    @context.observe @source_path, 'add', @add
    @context.observe @source_path, 'remove', @remove
  
  add: (value) =>
    new_context = new RangoObject
    key = Fleck.singularize @source_path
    hash = {}
    hash[key] = value
    new_context.set hash
    element = new @NodeInterpreter(@element_data, @scope, new_context, @document).element
    @elements[value] = element
  
  remove: (value) =>
    @elements[value].parentNode.removeChild @elements[value]
    delete @elements[value]
  
  addAll: ->
    for value in @context.get(@source_path)
      @add value

  removeAll: ->
    @remove value for value, element of @elements
  
  rebuild: =>
    @removeAll()
    @addAll()
