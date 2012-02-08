express = require 'express'
path = require 'path'
fs = require 'fs'
stylus = require 'stylus'
stitch = require 'stitch'

class Server
  constructor: (@options) ->
  
  start: ->
    app = express.createServer()
    
    # application css
    app.get '/application.css', (request, response) =>
      file = path.join @options.root_dir, 'app', 'stylesheets', 'main.styl'
      str = fs.readFileSync file, 'utf-8'
      stylus.render str, { filename: file }, (err, css) ->
        response.contentType 'text/css'
        response.send css
    
    
    
    # application.js
    app.get '/application.js', (request, response) =>
      wingman_client_dir = path.join __dirname, '../node_modules/wingman-client/lib'
      package = stitch.createPackage
        paths: [
          @options.root_dir + '/app'
          @options.root_dir + '/config'
          wingman_client_dir
        ]
      package.compile (err, source) ->
        source = """
          (function() {
            #{source}
            window.Wingman = require('wingman');
          })();
        """
        response.header 'Content-Type', 'application/x-javascript'
        response.send source
    
    # index.html
    app.get ///^(?!.*/assets).*$///, (request, response) =>
      file = path.join @options.root_dir, 'index.html'
      html = fs.readFileSync file, 'utf-8'
      response.send html
    
    #assets
    app.use "/assets", express.static(@options.root_dir + '/app/assets')
    
    
    
    
    
    @server = app.listen @options.port
  
  stop: ->
    @server.close()

module.exports = Server
