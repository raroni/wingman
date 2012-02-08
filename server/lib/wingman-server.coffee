express = require 'express'
path = require 'path'
fs = require 'fs'
stylus = require 'stylus'

class Server
  constructor: (@options) ->
  
  start: ->
    app = express.createServer()
    
    app.get '/application.css', (request, response) =>
      file = path.join @options.root_dir, 'app', 'stylesheets', 'main.styl'
      str = fs.readFileSync file, 'utf-8'
      stylus.render str, { filename: file }, (err, css) ->
        response.contentType('text/css');
        response.send css
    
    app.get ///^(?!.*/assets).*$///, (request, response) =>
      file = path.join @options.root_dir, 'index.html'
      html = fs.readFileSync file, 'utf-8'
      response.send html
    
    app.use "/assets", express.static(@options.root_dir + '/app/assets')
    
    @server = app.listen @options.port
  
  stop: ->
    @server.close()

module.exports = Server
