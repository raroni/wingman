Wingman = require '../../../wingman'

module.exports = class TextHandler
  constructor: (@options, @scope, @context) ->
    @textNode = Wingman.document.createTextNode @options.value
    @scope.appendChild @textNode
  
  remove: ->
    @textNode.parentNode.removeChild @textNode
