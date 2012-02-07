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
    response.on 'end', -> callback { body, statusCode: response.statusCode }

module.exports = class ModelTest extends Janitor.TestCase
  'async test server': ->
    app_dir = path.join __dirname, 'fixtures/sample_app'
    server = new Server { port: 5000, app_dir }
    server.start()
    
    get 'http://localhost:5000/', (response) =>
      @assertEqual 200, response.statusCode
      @assertContains response.body, 'It works'
      server.stop()
      @complete()
