stitch  = require 'stitch'
fs = require 'fs'

task 'build', 'Build dist file', ->
  paths = [
    __dirname + '/lib'
    __dirname + '/node_modules/strscan/lib'
    __dirname + '/node_modules/fleck/public/javascripts'
  ]

  jsPackage = stitch.createPackage {paths}
  jsPackage.compile (err, source) ->
    source = """
      (function(window) {
        #{source}
        window.Wingman = require('wingman');
      })(window);
    """
    fs.writeFileSync __dirname + '/wingman.js', source

task 'test', 'Run test suite', ->
  Janitor = require 'janitor'
  runner = new Janitor.NodeRunner { dir: __dirname + '/test/cases' }
  runner.run()
