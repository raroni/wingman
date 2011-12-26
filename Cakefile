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
        window.Rango = require('rango');
      })(window);
    """
    fs.writeFileSync __dirname + '/playground/rango.js', source
