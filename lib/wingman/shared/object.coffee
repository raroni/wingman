WingmanObject = module.exports = ->

Events = require './events'
Prototype = require './object/prototype'

WingmanObject.prototype = Prototype
WingmanObject.prototype.constructor = WingmanObject

WingmanObject.include = (hash) ->
  if hash.propertyDependencies
    setupPropertyDependencies.call @, hash.propertyDependencies
    delete hash.propertyDependencies
  else if hash.include
    modules = if Array.isArray hash.include then hash.include else [hash.include]
    WingmanObject.addProperties.call @prototype, module for module in modules
    delete hash.include
  
  WingmanObject.addProperties.call @prototype, hash

WingmanObject.create = (hash) ->
  instantiate this, hash

WingmanObject.extend = (prototype, classProperties) ->
  object = ->
  merge object, @
  merge object, classProperties
  
  object.prototype = Object.create @prototype
  WingmanObject.include.call object, prototype if prototype
  object.prototype.constructor = object
  
  object

WingmanObject.addProperties = (hash) ->
  addProperty.call @, key, value for key, value of hash

addProperty = (key, value) ->
  match = key.match(/^get([A-Z]{1}.*)$/)
  if match && typeof(value) == 'function'
    propertyName = match[1].replace /.{1}/, (v) -> v.toLowerCase()
    Object.defineProperty @, propertyName,
      get: value
      set: (value) ->
        Object.defineProperty @, propertyName, { value }
      enumerable: true
  else if typeof(value) == 'function'
    klass = @ # rename to prototype?
    @[key] = ->
      oldSuper = @_super
      @_super = Object.getPrototypeOf(klass)[key]
      result = value.apply @, arguments
      if oldSuper
        @_super = oldSuper
      else
        delete @_super
      result
  else if key of @
    @[key] = value
  else
    Object.defineProperty @, key,
      get: -> @getProperty key
      set: (value) -> @setProperty key, value
      enumerable: true
    @[key] = value

merge = (obj, obj2) ->
  obj[key] = value for key, value of obj2

setupPropertyDependencies = (propertyDependencyConfig) ->
  existing = @propertyDependencies?()
  @propertyDependencies = =>
    total = {}
    merge total, existing
    merge total, propertyDependencyConfig
    total

instantiate = (object, hash) ->
  instance = Object.create object.prototype
  WingmanObject.addProperties.call instance, hash if hash
  instance.initialize() if instance.initialize
  instance

WingmanObject.include Events
