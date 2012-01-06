Wingman = require '../wingman'

module.exports = class extends Wingman.Object
  constructor: (options) ->
    @el = Wingman.document.createElement 'div'
    options.parent_el.appendChild @el
   
    template = Wingman.Template.compile @templateSource()
    elements = template @
    for element in elements
      @el.appendChild element
  
  templateSource: ->
    @constructor.templates[@template_path]
