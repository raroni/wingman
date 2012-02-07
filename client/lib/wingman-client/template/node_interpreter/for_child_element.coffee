WingmanObject = require '../../shared/object'
Fleck = require 'fleck'
NodeInterpreter = require '../node_interpreter'

module.exports = class
  constructor: (@element_data, @scope, @context, @source_path) ->
    @elements = {}
    @addAll() if @source()
    @context.observe @source_path, @rebuild
    @context.observe @source_path, 'add', @add
    @context.observe @source_path, 'remove', @remove
  
  add: (value) =>
    new_context = new WingmanObject
    key = Fleck.singularize @source_path.split('.').pop()
    hash = {}
    hash[key] = value
    new_context.set hash
    element = new NodeInterpreter(@element_data, @scope, new_context).element
    @elements[value] = element
  
  remove: (value) =>
    @elements[value].parentNode.removeChild @elements[value]
    delete @elements[value]
  
  source: ->
    @context.get @source_path
  
  addAll: ->
    @source().forEach (value) => @add value
  
  removeAll: ->
    @remove value for value, element of @elements
  
  rebuild: =>
    @removeAll()
    @addAll() if @source()
