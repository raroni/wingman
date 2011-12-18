{StringScanner} = require "strscan"

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
    @scanForEndTag() || @scanForStartTag() || @scanForText()

  scanForEndTag: ->
    result = @scanner.scan /<\/(.*?)>/
    if result
      @current_scope = @current_scope.parent
    result
  
  scanForStartTag: ->
    result = @scanner.scan /<([a-zA-Z]+)>/
    if result
      new_element =
        tag: @scanner.getCapture(0)
        children: []
        parent: @current_scope
      @current_scope.children.push new_element
      @current_scope = new_element
    result

  scanForText: ->
    result = @scanner.scanUntil /</
    @current_scope.inner_html = result.substr 0, result.length-1
    @scanner.head -= 1
    result