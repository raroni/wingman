WingmanObject = require '../../shared/object'
Fleck = require 'fleck'
HandlerFactory = require '../handler_factory'

module.exports = class ForBlockHandler
  constructor: (@options, @context) ->
    @handlers = {}
    @addAll() if @source()
    @context.observe @options.source, @rebuild
    @context.observe @options.source, 'add', @add
    @context.observe @options.source, 'remove', @remove
  
  add: (value) =>
    @handlers[value] = []
    newContext = Object.create @context
    key = Fleck.singularize @options.source.split('.').pop()
    hash = {}
    hash[key] = value
    newContext.set hash
    
    for child in @options.children
      @handlers[value].push @createHandler(child, newContext)
  
  createHandler: (child, context) ->
    options = { scope: @options.scope }
    options[key] = value for key, value of child
    HandlerFactory.create options, context
  
  remove: (value) =>
    while @handlers[value].length
      handler = @handlers[value].pop()
      handler.remove()
    delete @handlers[value]
  
  source: ->
    @context.get @options.source
  
  addAll: ->
    @source().forEach (value) => @add value
  
  removeAll: ->
    @remove value for value, element of @handlers
  
  rebuild: =>
    @removeAll()
    @addAll() if @source()
