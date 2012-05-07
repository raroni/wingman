module.exports =
  bind: (eventName, func, context) ->
    throw new Error('Callback must be set!') unless func
    @_callbacks = {} unless @hasOwnProperty '_callbacks'
    @_callbacks[eventName] ||= []
    @_callbacks[eventName].push { func: func, context }
    @_callbacks
  
  unbind: (eventName, func, context) ->
    list = @hasOwnProperty('_callbacks') && @_callbacks[eventName]
    return false unless list
    
    for callback in list.slice()
      if callback.func == func && callback.context == context
        index = list.indexOf callback
        list.splice index, 1
  
  trigger: (args...) ->
    eventName = args.shift()
    list = @hasOwnProperty('_callbacks') && @_callbacks[eventName]
    return unless list
    
    for callback in list.slice()
      callback.func.apply callback.context || @, args
