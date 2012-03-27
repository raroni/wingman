{StringScanner} = require "strscan"
Value = require "./parser/value"

selfClosingTags = ['input', 'img', 'br', 'hr']

# TODO
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
    @currentScope = @tree
  
  execute: ->
    while !@done
      if @scanner.hasTerminated()
        @done = true
      else
        @scan()
  
  scan: ->
    @scanForEndTag() || @scanForStartTag() || @scanForIfToken() || @scanForElseToken() || @scanForViewToken() || @scanForForToken() || @scanForEndToken() || @scanForText()
  
  scanForEndTag: ->
    result = @scanner.scan /<\/(.*?)>/
    if result
      @currentScope = @currentScope.parent
    result
  
  scanForStartTag: ->
    result = @scanner.scan /<([a-zA-Z0-9]+) *(.*?)>/
    if result
      newNode =
        tag: @scanner.getCapture(0)
        children: []
        parent: @currentScope
        type: 'element'
      
      if @scanner.getCapture(1)
        attributes = @parseAttributes @scanner.getCapture(1)
        @addAttributes newNode, attributes
        
      @currentScope.children.push newNode
      @currentScope = newNode unless selfClosingTags.indexOf(newNode.tag) != -1
    result
  
  scanForForToken: ->
    result = @scanner.scan /\{for (.*?)\}/
    if result
      newNode =
        source: @scanner.getCapture(0)
        children: []
        parent: @currentScope
        type: 'for'
      @currentScope.children.push newNode
      @currentScope = newNode
    result
    
  scanForViewToken: ->
    result = @scanner.scan /\{view (.*?)\}/
    if result
      newNode =
        name: @scanner.getCapture(0)
        parent: @currentScope
        type: 'childView'
      @currentScope.children.push newNode
    result
    
  scanForIfToken: ->
    result = @scanner.scan /\{if (.*?)\}/
    if result
      newNode =
        source: @scanner.getCapture(0)
        parent: @currentScope
        type: 'conditional'
        children: []
      newNode.trueChildren = newNode.children
      @currentScope.children.push newNode
      @currentScope = newNode
    result
    
  scanForElseToken: ->
    result = @scanner.scan /\{else\}/
    if result
      @currentScope.children = @currentScope.falseChildren = []
    result
    
  scanForEndToken: ->
    result = @scanner.scan /\{end\}/
    if result
      delete @currentScope.children if @currentScope.type == 'conditional'
      @currentScope = @currentScope.parent
    result

  scanForText: ->
    result = @scanner.scanUntil /</
    @currentScope.value = new Value(result.substr 0, result.length-1)
    @scanner.head -= 1
    result

  parseAttributes: (attributesAsString) ->
    attributes = {}
    attributesAsString.replace(
      new RegExp('([a-z]+)="(.*?)"', "g"),
      ($0, $1, $2) ->
        attributes[$1] = $2
    )
    attributes
  
  parseStyle: (stylesAsString) ->
    re = new RegExp(' ', 'g')
    styles = {}
    for styleAsString in stylesAsString.replace(re, '').split(';')
      split = styleAsString.split ':'
      styles[split[0]] = new Value split[1]
    styles

  parseClass: (classesAsString) ->
    classes = []
    for klass in classesAsString.split(' ')
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
