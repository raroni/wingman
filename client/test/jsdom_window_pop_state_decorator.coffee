# As jsdom does not support neither window.history nor pushState, I made this decorator to fake it.

class History
  constructor: (@window) ->
  
  pushedStates: ->
    @_pushed_states ||= []
  
  pushState: (obj, title, location) ->
    event = { description: 'Im just a dummy event!', location }
    @pushedStates().push event
    @triggerPushEvent event
  
  triggerPushEvent: (event) ->
    @window.document.location.pathname = event.location
    if @window._popstate_callbacks?
      for callback in @window._popstate_callbacks
        callback event
  
  back: ->
    @pushedStates().pop()
    if @pushedStates().length
      @triggerPushEvent @pushedStates()[@pushedStates().length-1]

module.exports =
  create: (window) ->
    window.history = new History window
    original_add_event_listener = window.addEventListener
     
    window.addEventListener = (type, callback) ->
      if type == 'popstate'
        (window._popstate_callbacks ||= []).push callback
      else
        original_add_event_listener.call window, type, callback
    
    window
