Events = require './events'
Properties = require './object/properties'
Prototype = require './object/prototype'

WingmanObject = ->
WingmanObject.prototype = Prototype

WingmanObject.include = (hash) ->
  if hash.propertyDependencies
    setupPropertyDependencies.call @, hash.propertyDependencies
    delete hash.propertyDependencies
  
  addProperties.call @prototype, hash

WingmanObject.create = (hash) ->
  object = this.extend hash
  object.create()

WingmanObject.extend = (hash) ->
  object = ->
  object.prototype = Object.create @prototype
  WingmanObject.include.call object, hash if hash
  object.prototype.constructor = object
  object.create = -> instantiate object, arguments
  object.extend = WingmanObject.extend
  object

addProperties = (hash) ->
  addProperty.call @, key, value for key, value of hash

addProperty = (key, value) ->
  match = key.match(/^get([A-Z]{1}.*)$/)
  if match && typeof(value) == 'function'
    propertyName = match[1].replace /.{1}/, (v) -> v.toLowerCase()
    Object.defineProperty @, propertyName, { get: value }
  else if typeof(value) == 'function'
    @[key] = value
  else
    Object.defineProperty @, key,
      get: createGetter(key, value)
      set: createSetter(key)

setupPropertyDependencies = (value) ->
  @propertyDependencies = =>
    total = {}
    parent = Object.getPrototypeOf(@prototype).constructor
    if parent && parent.propertyDependencies
      total[k] = v for k, v of parent.propertyDependencies()
    total[k] = v for k, v of value
    total

convertIfNecessary = (value) ->
  if Array.isArray(value)
    addProperties.call value, Events
    
    value.push = ->
      Array.prototype.push.apply @, arguments
      @trigger 'add', arguments['0']
    
    value.remove = (value) ->
      index = @indexOf value
      if index != -1
        @splice index, 1
        @trigger 'remove', value
  
  value

createSetter = (key) ->
  (value) ->
    properties = Properties.findOrCreate @
    properties[key] = convertIfNecessary value
    @triggerPropertyChange key

createGetter = (key, defaultValue) ->
  ->
    properties = Properties.find @
    if properties && properties.hasOwnProperty key
      properties[key]
    else
      defaultValue

instantiate = (object, arguments) ->
  instance = Object.create object.prototype
  instance.initialize.apply instance, arguments if instance.initialize
  instance

WingmanObject.include Events

module.exports = WingmanObject
