if window?
  exports.document = window.document
  exports.window = window
  exports.localStorage = localStorage
exports.request = require('./wingman-client/request')
exports.Template = require('./wingman-client/template')
exports.View = require('./wingman-client/view')
exports.Model = require('./wingman-client/model')
exports.Controller = require('./wingman-client/controller')
exports.Application = require('./wingman-client/application')
