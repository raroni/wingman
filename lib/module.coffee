module.exports = class
  @include: (obj) ->
    throw 'Module.include requires obj' unless obj
    for key, value of obj
      @::[key] = value
    @
  
  @extend: (obj) ->
    throw 'Module.extend requires obj' unless obj
    for key, value of obj
      @[key] = value
    @
