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
    if @window._popstateCallbacks?
      for callback in @window._popstateCallbacks
        callback event
  
  go: (change) ->
    if change >= 0
      throw new Error "Going forward is not implemented!"
    else
      for [1..(-change)]
        @entries.pop()
    
    if @entries.length
      @triggerPushEvent @entries[@entries.length-1]

module.exports =
  create: (window) ->
    window.history = new History window
    originalAddEventListener = window.addEventListener
     
    window.addEventListener = (type, callback) ->
      if type == 'popstate'
        (window._popstateCallbacks ||= []).push callback
      else
        originalAddEventListener.call window, type, callback
    
    window
