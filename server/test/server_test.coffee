Janitor = require 'janitor'
Server = require '../.'

module.exports = class ModelTest extends Janitor.TestCase
  'test server instantiation': ->
    server = new Server
    @assert server
