WingmanObject = require './shared/object'

Template = WingmanObject.extend
  initialize: ->
    @tree = Parser.parse @source
  
  evaluate: (el, context) ->
    options = { el, type: 'element' }
    options[key] = value for key, value of @tree
    HandlerFactory.create options, context

Template.compile = (source) ->
  template = @create { source }
  (el, context) ->
    template.evaluate el, context

Parser = require './template/parser'
HandlerFactory = require './template/handler_factory'
Fleck = require 'fleck'

module.exports = Template
