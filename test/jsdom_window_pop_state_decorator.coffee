# As jsdom does not support neither window.history nor pushState, I made this decorator to fake it.

class History
  constructor: (@window) ->
  
  pushState: (obj, title, location) ->
    event = { description: 'Im just a dummy event!' }
    @window.document.location.pathname = location
    for callback in @window._popstate_callbacks
      callback event

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
