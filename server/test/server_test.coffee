Janitor = require 'janitor'
Server = require '../.'
http = require 'http'
path = require 'path'
URL = require 'url'


get = (url, callback) ->
  parsed_url = URL.parse url
  http.get host: parsed_url.hostname, port: parsed_url.port, path: parsed_url.path, (response) =>
    body = ''
    response.on 'data', (chunk) -> body += chunk
    response.on 'end', -> callback { body, statusCode: response.statusCode, headers: response.headers }

next_port = 5000
createServer = (root_dir) ->
  next_port++
  new Server { port: next_port, root_dir }

module.exports = class ModelTest extends Janitor.TestCase
  'async test root path of server': ->
    root_dir = path.join __dirname, 'fixtures/sample_app'
    server = createServer root_dir
    server.start()
    
    get "http://localhost:#{server.options.port}/", (response) =>
      @assertEqual 200, response.statusCode
      @assertContains response.body, '<html>'
      @assertEqual response.headers['content-type'], 'text/html; charset=utf-8'
      @assertContains response.body, 'It works'
      server.stop()
      @complete()
  
  'async test random non assets path without file extensions': ->
    root_dir = path.join __dirname, 'fixtures/sample_app'
    server = createServer root_dir
    server.start()
    
    get "http://localhost:#{server.options.port}/something", (response) =>
      @assertEqual 200, response.statusCode
      @assertContains response.body, '<html>'
      @assertEqual response.headers['content-type'], 'text/html; charset=utf-8'
      @assertContains response.body, 'It works'
      server.stop()
      @complete()
  
  'async test asset file': ->
    root_dir = path.join __dirname, 'fixtures/sample_app'
    server = createServer root_dir
    server.start()
    
    get "http://localhost:#{server.options.port}/assets/txts/test.txt", (response) =>
      @assertEqual 200, response.statusCode
      @assertEqual response.body, 'I am a VERY happy assets! :D'
      @assertEqual response.headers['content-type'], 'text/plain; charset=UTF-8'
      server.stop()
      @complete()
