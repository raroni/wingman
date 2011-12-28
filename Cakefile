stitch  = require 'stitch'
fs = require 'fs'

task 'build', 'Build dist file', ->
  paths = [
    __dirname + '/lib'
    __dirname + '/node_modules/strscan/lib'
    __dirname + '/node_modules/fleck/public/javascripts'
  ]

  package = stitch.createPackage {paths}
  package.compile (err, source) ->
    source = """
      (function(window) {
        #{source}
        window.Wingman = require('wingman');
      })(window);
    """
    fs.writeFileSync __dirname + '/playground/wingman.js', source

task 'test', 'Run test suite', ->
  Janitor = require 'janitor'
  runner = new Janitor.NodeRunner { dir: __dirname + '/test' }
  runner.run()
