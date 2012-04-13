WingmanObject = require '../../shared/object'
Fleck = require 'fleck'
HandlerFactory = require '../handler_factory'

module.exports = class ForBlockHandler
  constructor: (@options, @scope, @context) ->
    @handlers = {}
    @addAll() if @source()
    @context.observe @options.source, @rebuild
    @context.observe @options.source, 'add', @add
    @context.observe @options.source, 'remove', @remove
  
  add: (value) =>
    @handlers[value] = []
    
    newContext = new WingmanObject
    if @context.createChild
      # The line below would be prettier, but Function#bind is not supported on iOS5.
      # newContext.createChild = @context.createChild.bind @context
      newContext.createChild = (args...) => @context.createChild.call @context, args...
    key = Fleck.singularize @options.source.split('.').pop()
    hash = {}
    hash[key] = value
    newContext.set hash
    
    for newoptions in @options.children
      handler = HandlerFactory.create newoptions, @scope, newContext
      @handlers[value].push handler
  
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
