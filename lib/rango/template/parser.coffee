{StringScanner} = require "strscan"
Value = require "./parser/value"

module.exports = class
  @parse: (source) ->
    parser = new @ source
    parser.execute()
    parser.tree

  constructor: (source) ->
    @scanner = new StringScanner source
    @tree = { children: [] }
    @current_scope = @tree

  execute: ->
    while !@done
      if @scanner.hasTerminated()
        @done = true
      else
        @scan()
  
  scan: ->
    @scanForEndTag() || @scanForStartTag() || @scanForForToken() || @scanForEndToken() || @scanForText()
  
  scanForEndTag: ->
    result = @scanner.scan /<\/(.*?)>/
    if result
      @current_scope = @current_scope.parent
    result
  
  scanForStartTag: ->
    result = @scanner.scan /<([a-zA-Z]+) *(.*?)>/
    if result
      new_node =
        tag: @scanner.getCapture(0)
        children: []
        parent: @current_scope
        type: 'element'

      if @scanner.getCapture(1)
        properties = @parseProperties @scanner.getCapture(1)
        if properties.style
          new_node.styles = @parseStyle properties.style

      @current_scope.children.push new_node
      @current_scope = new_node
    result
    
  scanForForToken: ->
    result = @scanner.scan /\{for (.*?)\}/
    if result
      new_node =
        source: @scanner.getCapture(0)
        children: []
        parent: @current_scope
        type: 'for'
      @current_scope.children.push new_node
      @current_scope = new_node
    result
    
  scanForEndToken: ->
    result = @scanner.scan /\{end\}/
    if result
      @current_scope = @current_scope.parent
    result

  scanForText: ->
    result = @scanner.scanUntil /</
    @current_scope.value = new Value(result.substr 0, result.length-1)
    @scanner.head -= 1
    result

  parseProperties: (properties_as_string) ->
    properties = {}
    properties_as_string.replace(
      new RegExp('([a-z]+)="(.*?)"', "g"),
      ($0, $1, $2) ->
        properties[$1] = $2
    )
    properties
  
  parseStyle: (styles_as_string) ->
    styles = {}
    for style_as_string in styles_as_string.replace(' ', '').split(';')
      split = style_as_string.split ':'
      styles[split[0]] = new Value split[1]
    styles
