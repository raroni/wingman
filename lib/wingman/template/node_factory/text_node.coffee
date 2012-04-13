Wingman = require '../../../wingman'

module.exports = class TextNode
  constructor: (@nodeData, @scope, @context) ->
    @textNode = Wingman.document.createTextNode @nodeData.value
    @scope.appendChild @textNode
  
  remove: ->
    @textNode.parentNode.removeChild @textNode
