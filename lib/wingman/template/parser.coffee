WingmanObject = require '../shared/object'
{StringScanner} = require "strscan"

selfClosingTags = ['input', 'img', 'br', 'hr']

# TODO
# REFACTORING IDEA: Let each individual node type have its own class.
# That would make it possible to extract parseStyle, parseClass and so on into a ElementNode class or the like
# This would in turn make this class simpler :)

buildText = (value) ->
  value = value.substring 1, value.length-1 if isDynamic = value.match /^\{(.*?)\}$/
  
  newNode = {
    type: 'text'
    value
    isDynamic
  }

Parser = WingmanObject.extend
  initialize: (source) ->
    @scanner = new StringScanner trimSource(source)
    @tree = { children: [] }
    @currentScope = @tree
  
  execute: ->
    while !@done
      if @scanner.hasTerminated()
        @done = true
      else
        @scan()
  
  scan: ->
    @scanForEndTag() || @scanForStartTag() || @scanForIfToken() || @scanForElseToken() || @scanForViewToken() || @scanForForToken() || @scanForEndToken() || @scanForSource() || @scanForText()
  
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
    result = @scanner.scan /\{view ([a-zA-Z\.']+)(,{1} {1}(.*?))?\}/
    if result
      identifier = @scanner.getCapture(0)
      options = @scanner.getCapture(2)
      
      newNode =
        parent: @currentScope
        type: 'childView'
      
      if options
        optionRegex = /(\w+): \[(.*?)\]/g
        while option = optionRegex.exec(options)
          if option[1] == 'properties'
            newNode.properties = option[2].replace(/\'| /g, '').split ','
      
      if identifier[0] == "'"
        newNode.name = identifier.replace /\'/g, ''
      else
        newNode.path = identifier
      
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
  
  scanForSource: ->
    result = @scanner.scan /\{[a-zA-Z\.]+\}\<\//
    if result
      value = result.substr 1, result.length-4
      @currentScope.source = value
      @scanner.head -= 2
    else
      result = @scanner.scan /\{[a-zA-Z\.]+\}$/
      if result
        value = result.substr 1, result.length-2
        @currentScope.source = value
    result
  
  scanForText: ->
    result = @scanner.scanUntil /</
    if result
      value = result.substr 0, result.length-1
      newNode = buildText value
      
      @currentScope.children.push newNode
      @scanner.head -= 1
    else
      value = @scanner.scanUntil /$/
      newNode = buildText value
      @currentScope.children.push newNode
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
      styles[split[0]] = buildText split[1]
    styles

  parseClass: (classesAsString) ->
    classes = []
    for klass in classesAsString.split(' ')
      classes.push buildText(klass)
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
        node.attributes[key] = buildText value

Parser.parse = (source) ->
  parser = new @ source
  parser.execute()
  parser.tree

trimSource = (source) ->
  lines = []
  for line in source.split "\n"
    lines.push line.replace(/^ +/, '')
  lines.join('').replace /[\n\r\t]/g, ''

module.exports = Parser
