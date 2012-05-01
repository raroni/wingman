Wingman = require '../../../wingman'

module.exports = Wingman.Object.extend
  initialize: ->
    @textNode = Wingman.document.createTextNode @options.value
    @options.scope.appendChild @textNode
  
  remove: ->
    @textNode.parentNode.removeChild @textNode
