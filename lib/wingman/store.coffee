Collection = require './store/collection'
WingmanObject = require './shared/object'

module.exports = WingmanObject.extend
  initialize: ->
    @collections = {}
    @collectionClass ||= Collection
    @classes = []
  
  collection: (klass) ->
    if @collections[@classId(klass)]
      @collections[@classId(klass)]
    else
      @collections[@classId(klass)] = new @collectionClass
      @collections[@classId(klass)]
  
  flush: ->
    collection.flush() for klass, collection of @collections
  
  classId: (klass) ->
    id = @classes.indexOf klass
    if id == -1
      @createClassId klass
    else
      id
  
  createClassId: (klass) ->
    @classes.push klass
    @classes.length-1
