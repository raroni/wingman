Wingman = require '../../../wingman'

module.exports = class TextHandler
  constructor: (@options, @context) ->
    @textNode = Wingman.document.createTextNode @options.value
    @options.scope.appendChild @textNode
  
  remove: ->
    @textNode.parentNode.removeChild @textNode
