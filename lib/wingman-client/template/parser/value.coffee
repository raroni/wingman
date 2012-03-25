module.exports = class
  constructor: (@body) ->
    match = @body.match /^\{(.*?)\}$/
    @isDynamic = !!match
    @body = match[1] if @isDynamic
  
  get: (context) ->
    if @isDynamic && context
      context.get @body
    else
      @body
