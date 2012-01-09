Wingman = require '../wingman'

module.exports = class extends Wingman.Object
  @parseEvents: (events_hash) ->
    (@parseEvent(key, trigger) for key, trigger of events_hash)
  
  @parseEvent: (key, trigger) ->
    type = key.split(' ')[0]
    {
      selector: key.substring(type.length + 1)
      type
      trigger
    }
  
  constructor: (options) ->
    @el = Wingman.document.createElement 'div'
    @template_path = options.template_path if options.template_path
    options.parent_el.appendChild @el
   
    template = Wingman.Template.compile @templateSource()
    elements = template @
    @el.appendChild element for element in elements
    @setupEvents() if @events?
  
  templateSource: ->
    @constructor.template_sources[@template_path]

  setupEvents: ->
    @setupEvent event for event in @constructor.parseEvents(@events)
  
  setupEvent: (event) ->
    @el.addEventListener event.type, (e) =>
      for elm in Array.prototype.slice.call(@el.querySelectorAll(event.selector), 0)
        @trigger event.trigger if elm == e.target
