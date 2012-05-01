Events = require './events'
Properties = require './object/properties'
Prototype = require './object/prototype'

WingmanObject = ->
WingmanObject.prototype = Prototype
WingmanObject.prototype.constructor = WingmanObject

WingmanObject.include = (hash) ->
  if hash.propertyDependencies
    setupPropertyDependencies.call @, hash.propertyDependencies
    delete hash.propertyDependencies
  
  addProperties.call @prototype, hash

WingmanObject.create = (hash) ->
  instantiate this, hash

WingmanObject.extend = (hash) ->
  object = ->
  object.prototype = Object.create @prototype
  WingmanObject.include.call object, hash if hash
  object.prototype.constructor = object
  object.create = WingmanObject.create
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
  else if key of @
    @[key] = value
  else
    Object.defineProperty @, key,
      get: createGetter(key, value)
      set: createSetter(key)
    @[key] = value

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
    oldValue = properties[key]
    properties[key] = convertIfNecessary value
    @triggerPropertyChange key, oldValue

createGetter = (key, defaultValue) ->
  ->
    properties = Properties.findOrCreate @
    properties[key]

instantiate = (object, hash) ->
  instance = Object.create object.prototype
  addProperties.call instance, hash if hash
  instance.initialize() if instance.initialize
  instance

WingmanObject.include Events

module.exports = WingmanObject
