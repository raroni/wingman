exports.document = document if window?
exports.request = require('./wingman/request')
exports.Template = require('./wingman/template')
exports.View = require('./wingman/view')
exports.Model = require('./wingman/model')
exports.Controller = require('./wingman/controller')
exports.App = require('./wingman/app')
