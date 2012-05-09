if window?
  exports.document = window.document
  exports.window = window
  exports.global = window
  exports.localStorage = localStorage

exports.Object = require('./wingman/shared/object')

exports.Object = class extends require('./wingman/shared/object')
  
exports.request = require('./wingman/request')
exports.Template = require('./wingman/template')
exports.View = require('./wingman/view')
exports.Store = require('./wingman/store')
exports.Model = require('./wingman/model')
exports.Controller = require('./wingman/controller')
exports.Application = require('./wingman/application')
exports.Module = require('./wingman/shared/module')
exports.Events = require('./wingman/shared/events')

exports.store = ->
  if @_store
    @_store
  else
    @_store = exports.Store.create()
    @_store
