module.exports =
  bind: (event_name, callback) ->
    @_callbacks ||= {}
    @_callbacks[event_name] ||= []
    @_callbacks[event_name].push callback

  unbind: (event_name, callback) ->
    list = @_callbacks && @_callbacks[event_name]
    return false unless list
    index = list.indexOf callback
    list.splice index, 1

  trigger: (args...) ->
    event_name = args.shift()
    list = @_callbacks && @_callbacks[event_name]
    return unless list
    callback.apply @, args for callback in list
