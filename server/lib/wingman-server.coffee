express = require 'express'
path = require 'path'
fs = require 'fs'
stylus = require 'stylus'
stitch = require 'stitch'
glob = require 'glob'

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
      
      requires = ['application']
      app_dirs = ['helpers', 'models', 'views', 'controllers']
      for app_dir in app_dirs
        glob_search_string = path.join @options.root_dir, 'app', app_dir, '**.coffee'
        files = glob.sync glob_search_string
        files = files.sort (a, b) ->
          reg_exp = ///////g
          myCount = (str) ->
            str.match(reg_exp).length
          if myCount(a) > myCount(b) then 1 else -1
        requires.push file.replace(path.join(@options.root_dir, 'app'), '').substring(1).replace(".coffee", "") for file in files
      
      js_requires = ""
      for require in requires
        js_requires += "require('#{require}');\n"
      
      
      #templates
      
      templates = {}
      prefix = path.join @options.root_dir, 'app', 'templates'
      template_paths = glob.sync path.join(prefix, '**.whtml')
      for template_path in template_paths
        key = template_path.replace(prefix, '').replace('.whtml', '').replace(/\//g, '.')
        templates[key] = fs.readFileSync template_path, 'utf-8'
      
      package.compile (err, source) ->
        source = """
          (function() {
            #{source}
            window.Wingman = require('wingman');
            window.Wingman.View.template_sources = #{JSON.stringify(templates)}
            #{js_requires}
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
