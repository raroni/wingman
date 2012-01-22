if window?
  exports.document = window.document
  exports.window = window
exports.request = require('./wingman/request')
exports.Template = require('./wingman/template')
exports.View = require('./wingman/view')
exports.Model = require('./wingman/model')
exports.Controller = require('./wingman/controller')
exports.App = require('./wingman/app')
