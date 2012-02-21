# As jsdom does not support neither window.history nor pushState, I made this decorator to fake it.

class History
  constructor: (@window) ->
    @entries = []
  
  pushState: (obj, title, location) ->
    event = { state: obj, location }
    @entries.push event
    @window.document.location.pathname = event.location
  
  triggerPushEvent: (event) ->
    @window.document.location.pathname = event.location
    if @window._popstate_callbacks?
      for callback in @window._popstate_callbacks
        callback event
  
  back: (times = 1) ->
    @entries.pop() for [1..times]
    if @entries.length
      @triggerPushEvent @entries[@entries.length-1]

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
