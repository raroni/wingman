Properties = require './object/properties'

addProperties = (hash) ->
  addProperty.call @, key, value for key, value of hash

addProperty = (key, value) ->
  match = key.match(/^get([A-Z]{1}.*)$/)
  if match && typeof(value) == 'function' && value.length == 0
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

instantiate = (object, args) ->
  instance = Object.create object.prototype
  instance.initialize.apply instance, args if instance.initialize
  instance

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


WingmanObject = module.exports = ->

WingmanObject.include = (args...) ->
  addProperties.call @, module for module in args

WingmanObject.include
  create: (args...) ->
    instantiate this, args

  extend: (prototype, classProperties) ->
    object = ->
    merge object, @
    merge object, classProperties
    
    object.prototype = Object.create @prototype
    object.prototype.include prototype if prototype
    object.prototype.constructor = object
    
    object

  set: (hash) ->
    @[key] = value for key, value of hash
  
  get: (chainAsString) ->
    chain = chainAsString.split '.'
    if chain.length == 1
      @[chain[0]]
    else
      nestedPropertyName = chain.shift()
      nestedProperty = @[nestedPropertyName]
      if nestedProperty
        nestedProperty.get chain.join('.')
      else
        undefined
  
  setProperty: (key, value) ->
    properties = Properties.findOrCreate @
    oldValue = properties[key] if @triggerPropertyChange
    properties[key] = convertIfNecessary value
    @triggerPropertyChange key, oldValue if @triggerPropertyChange
  
  getProperty: (key) ->
    properties = Properties.findOrCreate @
    properties[key]
  
  addPropertyDependencies: (hash) ->
    properties = Properties.findOrCreate @
    properties.propertyDependencies ||= {}
    merge properties.propertyDependencies, hash
  
  propertyDependencies: ->
    properties = Properties.findOrCreate @
    if properties.propertyDependencies
      total = {}
      merge total, properties.propertyDependencies
      parent = Object.getPrototypeOf(@prototype).constructor
      merge total, parent.propertyDependencies() if parent
      total

Prototype = require './object/prototype'
WingmanObject.prototype = Prototype
WingmanObject.prototype.constructor = WingmanObject

Events = require './events'
WingmanObject.include Events
