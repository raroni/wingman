module.exports =
  bind: (eventName, callback) ->
    throw new Error('Callback must be set!') unless callback
    @_callbacks = {} unless @hasOwnProperty '_callbacks'
    @_callbacks[eventName] ||= []
    @_callbacks[eventName].push callback
    @_callbacks

  unbind: (eventName, callback) ->
    list = @hasOwnProperty('_callbacks') && @_callbacks[eventName]
    return false unless list
    index = list.indexOf callback
    list.splice index, 1

  trigger: (args...) ->
    eventName = args.shift()
    list = @hasOwnProperty('_callbacks') && @_callbacks[eventName]
    return unless list
    for callback in list.slice()
      callback.apply @, args
