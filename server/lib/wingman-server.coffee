express = require 'express'
path = require 'path'
fs = require 'fs'

class Server
  constructor: (@options) ->
  
  start: ->
    app = express.createServer()
    app.get ///^(?!.*/assets).*$///, (request, response) =>
      file = path.join @options.app_dir, 'index.html'
      html = fs.readFileSync file, 'utf-8'
      response.send html
    
    @server = app.listen @options.port
  
  stop: ->
    @server.close()

module.exports = Server
