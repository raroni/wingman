module.exports = class
  constructor: (@body) ->
    match = @body.match /^\{(.*?)\}$/
    @is_dynamic = !!match
    @body = match[1] if @is_dynamic
  
  get: (context) ->
    @body
