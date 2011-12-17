module.exports =
  bind: (event_name, callback) ->
    @_callbacks ||= {}
    @_callbacks[event_name] ||= []
    @_callbacks[event_name].push callback

  trigger: (args...) ->
    event_name = args.shift()
    list = @_callbacks && @_callbacks[event_name]
    return unless list
    callback.apply @, args for callback in list
