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
  else if typeof(value) == 'function' || key of @
    @[key] = value
  else
    @staticPropertyNames = [] unless @hasOwnProperty 'staticPropertyNames'
    @staticPropertyNames.push key
    Object.defineProperty @, key,
      get: -> @getProperty key
      set: (value) -> @setProperty key, value
      enumerable: true
    @[key] = value

merge = (obj, obj2) ->
  obj[key] = value for key, value of obj2

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
  extend: (prototype, classProperties) ->
    object = ->
      @initialize.apply @, arguments if @initialize
      undefined
    
    merge object, @
    merge object, classProperties
    
    object._super = @prototype
    
    object.prototype = Object.create @prototype
    object.prototype.constructor = object
    object.prototype.include prototype if prototype
    
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
    oldValue = @["_#{key}"] if @triggerPropertyChange
    @["_#{key}"] = convertIfNecessary value
    @triggerPropertyChange key, oldValue if @triggerPropertyChange
  
  getProperty: (key) ->
    @["_#{key}"]
  
  addPropertyDependencies: (hash) ->
    @prototype.propertyDependencies = {} unless @prototype.hasOwnProperty 'propertyDependencies'
    merge @prototype.propertyDependencies, hash
  
  propertyDependencies: ->
    parent = Object.getPrototypeOf(@prototype).constructor
    
    total = {}
    merge total, @prototype.propertyDependencies if @prototype.propertyDependencies
    merge total, parent.propertyDependencies() if parent.propertyDependencies?
    total

Prototype = require './object/prototype'
WingmanObject.prototype = Prototype
WingmanObject.prototype.constructor = WingmanObject

Events = require './events'
WingmanObject.include Events
