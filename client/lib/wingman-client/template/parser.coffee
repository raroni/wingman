{StringScanner} = require "strscan"
Value = require "./parser/value"

self_closing_tags = ['input', 'img', 'br', 'hr']

# REFACTORING IDEA: Let each individual node type have its own class.
# That would make it possible to extract parseStyle, parseClass and so on into a ElementNode class or the like
# This would in turn make this class simpler :)

module.exports = class
  @parse: (source) ->
    parser = new @ source
    parser.execute()
    parser.tree
  
  @trimSource: (source) ->
    lines = []
    for line in source.split "\n"
      lines.push line.replace(/^ +/, '')
    lines.join('').replace /[\n\r\t]/g, ''
  
  constructor: (source) ->
    @scanner = new StringScanner @constructor.trimSource(source)

    @tree = { children: [] }
    @current_scope = @tree
  
  execute: ->
    while !@done
      if @scanner.hasTerminated()
        @done = true
      else
        @scan()
  
  scan: ->
    @scanForEndTag() || @scanForStartTag() || @scanForViewToken() || @scanForForToken() || @scanForEndToken() || @scanForText()
  
  scanForEndTag: ->
    result = @scanner.scan /<\/(.*?)>/
    if result
      @current_scope = @current_scope.parent
    result
  
  scanForStartTag: ->
    result = @scanner.scan /<([a-zA-Z0-9]+) *(.*?)>/
    if result
      new_node =
        tag: @scanner.getCapture(0)
        children: []
        parent: @current_scope
        type: 'element'

      if @scanner.getCapture(1)
        attributes = @parseAttributes @scanner.getCapture(1)
        @addAttributes new_node, attributes

      @current_scope.children.push new_node
      @current_scope = new_node unless self_closing_tags.indexOf(new_node.tag) != -1
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
    
  scanForViewToken: ->
    result = @scanner.scan /\{view (.*?)\}/
    if result
      new_node =
        name: @scanner.getCapture(0)
        parent: @current_scope
        type: 'child_view'
      @current_scope.children.push new_node
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

  parseAttributes: (attributes_as_string) ->
    attributes = {}
    attributes_as_string.replace(
      new RegExp('([a-z]+)="(.*?)"', "g"),
      ($0, $1, $2) ->
        attributes[$1] = $2
    )
    attributes
  
  parseStyle: (styles_as_string) ->
    re = new RegExp(' ', 'g')
    styles = {}
    for style_as_string in styles_as_string.replace(re, '').split(';')
      split = style_as_string.split ':'
      styles[split[0]] = new Value split[1]
    styles

  parseClass: (classes_as_string) ->
    classes = []
    for klass in classes_as_string.split(' ')
      classes.push new Value(klass)
    classes
  
  addAttributes: (node, attributes) ->
    if attributes.style
      node.styles = @parseStyle attributes.style
      delete attributes.style
    if attributes.class
      node.classes = @parseClass attributes.class
      delete attributes.class
    if Object.keys(attributes).length != 0
      node.attributes = {}
      for key, value of attributes
        node.attributes[key] = new Value(value)
