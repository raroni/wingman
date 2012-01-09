Wingman = require '../wingman'

module.exports = class extends Wingman.Object
  constructor: (hash) ->
    for key, value of hash
      h = {}
      h[key] = value
      @set h
