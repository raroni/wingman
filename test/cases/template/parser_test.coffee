Parser = require '../../../lib/wingman/template/parser'
Janitor = require 'janitor'

module.exports = class ParserTest extends Janitor.TestCase
  parse: (source) ->
    Parser.parse source
  
  'test text string': ->
    tree = @parse 'hello everybody'
    @assertEqual 1, tree.children.length
    
    textChild = tree.children[0]
    @assertEqual 'text', textChild.type
    @assertEqual 'hello everybody', textChild.value
    @assert !textChild.children
  
  'test empty tag': ->
    tree = @parse '<div></div>'
    
    @assertEqual 1, tree.children.length
    @assertEqual 'div', tree.children[0].tag
    @assertEqual 'element', tree.children[0].type
    @assertEqual 0, tree.children[0].children.length
  
  'test empty tag with tag name containing numbers': ->
    tree = @parse '<h1></h1>'
    
    @assertEqual 1, tree.children.length
    @assertEqual 'h1', tree.children[0].tag
  
  'test tag with static text': ->
    tree = @parse '<div>hi</div>'
    
    @assertEqual 1, tree.children.length
    @assertEqual 'div', tree.children[0].tag
    
    textNode = tree.children[0].children[0]
    
    @assertEqual 'text', textNode.type
    @assertEqual 'hi', textNode.value
  
  'test use of newlines and tabs': ->
    templateSource = """
      <div>
        Raz to the mouse!
      </div>
    """
    
    tree = @parse templateSource
    
    @assertEqual 1, tree.children.length
    @assertEqual 'div', tree.children[0].tag
    @assertEqual 'Raz to the mouse!', tree.children[0].children[0].value
  
  'test multiple tags': ->
    tree = @parse '<div>one</div><span>two</span>'
    
    @assertEqual 2, tree.children.length
    
    firstElement = tree.children[0]
    @assertEqual 'div', firstElement.tag
    @assertEqual 'one', firstElement.children[0].value
    
    lastElement = tree.children[1]
    @assertEqual 'span', lastElement.tag
    @assertEqual 'two', lastElement.children[0].value
  
  'test nested tags': ->
    tree = @parse '<ol><li>One</li><li>Two</li></ol>'
    
    @assertEqual 1, tree.children.length
    
    firstElement = tree.children[0]
    @assertEqual 'ol', firstElement.tag
    
    for value, i in ['One', 'Two']
      element = firstElement.children[i]
      @assertEqual 'li', element.tag
      @assertEqual value, element.children[0].value
  
  'test bare source': ->
    tree = @parse '{name}'
    @assertEqual 0, tree.children.length
    @assertEqual 'name', tree.source
  
  'test tag with source': ->
    tree = @parse '<div>{greeting}</div>'
    
    @assertEqual 1, tree.children.length
    
    divNode = tree.children[0]
    @assertEqual 'div', divNode.tag
    @assertEqual 'greeting', divNode.source
  
  'test tag with source with two words in its name': ->
    tree = @parse '<div>{myName}</div>'
    
    @assertEqual 1, tree.children.length
    
    divNode = tree.children[0]
    @assertEqual 'div', divNode.tag
    @assertEqual 'myName', divNode.source
  
  'test for token': ->
    tree = @parse '<ol>{for users}<li>{user}</li>{end}</ol>'
    
    @assertEqual 1, tree.children.length
    
    olNode = tree.children[0]
    forNode = olNode.children[0]
    @assertEqual 'for', forNode.type
    @assertEqual 'users', forNode.source
    
    liElm = forNode.children[0]
    @assertEqual 'li', liElm.tag
    @assertEqual 'user', liElm.source
  
  'test element with single static style': ->
    tree = @parse '<div style="color: red">funky text</div>'
    
    @assertEqual 1, tree.children.length
    styles = tree.children[0].styles
    @assert styles
    colorStyle = styles.color
    @assertEqual 'red', colorStyle.value
    @assert !colorStyle.isDynamic
  
  'test element with single dynamic style': ->
    tree = @parse '<div style="color: {color}">funky text</div>'
    
    @assertEqual 1, tree.children.length
    styles = tree.children[0].styles
    @assert styles
    colorStyle = styles.color
    @assertEqual 'color', colorStyle.value
    @assert colorStyle.isDynamic
  
  'test element with several static styles': ->
    tree = @parse '<div style="color: blue; font-size: 14px">funky text</div>'
    
    @assertEqual 1, tree.children.length
    element = tree.children[0]
    styles = element.styles
    @assert styles
    
    colorStyle = styles.color
    @assertEqual 'blue', colorStyle.value
    @assert !colorStyle.isDynamic
    
    fontSizeStyle = styles['font-size']
    @assertEqual '14px', fontSizeStyle.value
    @assert !fontSizeStyle.isDynamic
  
  'test element with static and dynamic styles': ->
    tree = @parse '<div style="color: blue; font-size: {someFontSize}">funky text</div>'
    
    @assertEqual 1, tree.children.length
    styles = tree.children[0].styles
    @assert styles
    
    colorStyle = styles.color
    @assertEqual 'blue', colorStyle.value
    @assert !colorStyle.isDynamic
    
    fontSizeStyle = styles['font-size']
    @assertEqual 'someFontSize', fontSizeStyle.value
    @assert fontSizeStyle.isDynamic
  
  'test element with single static class': ->
    tree = @parse '<div class="funny_class">funky text</div>'
    classes = tree.children[0].classes
    @assert classes
    @assertEqual 1, classes.length
    firstClass = classes[0]
    @assertEqual 'funny_class', firstClass.value
    @assert !firstClass.isDynamic
  
  'test element with two static classes': ->
    tree = @parse '<div class="funny_class another_funny_class">funky text</div>'
    classes = tree.children[0].classes
    @assert classes
    @assertEqual 2, classes.length
    @assertEqual 'funny_class', classes[0].value
    @assertEqual 'another_funny_class', classes[1].value
    @assert !klass.isDynamic for klass in classes
  
  'test element with single dynamic class': ->
    tree = @parse '<div class="{funnyClass}">funky text</div>'
    classes = tree.children[0].classes
    @assert classes
    @assertEqual 1, classes.length
    
    firstClass = classes[0]
    @assertEqual 'funnyClass', firstClass.value
    @assert firstClass.isDynamic
  
  'test element with two dynamic classes': ->
    tree = @parse '<div class="{funnyClass} {anotherFunnyClass}">funky text</div>'
    classes = tree.children[0].classes
    @assert classes
    @assertEqual 2, classes.length
    @assertEqual 'funnyClass', classes[0].value
    @assertEqual 'anotherFunnyClass', classes[1].value
    @assert klass.isDynamic for klass in classes
  
  'test non closing tag': ->
    tree = @parse '<div><input></div><div>something else</div>'
    
    divs = tree.children
    @assertEqual 2, divs.length
    @assertEqual 1, divs[0].children.length
    
    input = divs[0].children[0]
    @assertEqual 'element', input.type
    @assertEqual 'input', input.tag
  
  'test tag combined with child view': ->
    tree = @parse '<h1>Some title</h1>{view user}'
    
    nodes = tree.children
    @assertEqual 2, nodes.length
    
    childViewNode = nodes[1]
    
    @assertEqual 'childView', childViewNode.type
    @assertEqual 'user', childViewNode.name
  
  'test regular attributes': ->
    tree = @parse '<input name="email" placeholder="Email...">'
    nodes = tree.children
    
    @assertEqual 1, nodes.length
    input = nodes[0]
    @assertEqual 'element', input.type
    @assertEqual 'input', input.tag
    @assert input.attributes
    @assertEqual 2, Object.keys(input.attributes).length
    @assertEqual 'email', input.attributes.name.value
    @assertEqual 'Email...', input.attributes.placeholder.value

  'test regular attributes with dynamic values': ->
    tree = @parse '<img src="{mySrc}">'
    nodes = tree.children
    
    @assertEqual 1, nodes.length
    input = nodes[0]
    @assertEqual 'element', input.type
    @assertEqual 'img', input.tag
    @assert input.attributes
    @assertEqual 1, Object.keys(input.attributes).length
    @assertEqual 'mySrc', input.attributes.src.value
    @assert input.attributes.src.isDynamic
    
  'test simple conditional': ->
    tree = @parse '{if something}<div>hej</div>{end}'
    nodes = tree.children
    
    @assertEqual 1, nodes.length
    node = nodes[0]
    @assertEqual 'conditional', node.type
    @assertEqual 'something', node.source
    @assert !node.children
    
    children = node.trueChildren
    @assertEqual 1, children.length
    
    div = children[0]
    @assertEqual 'element', div.type
    @assertEqual 'div', div.tag
    @assertEqual 'hej', div.children[0].value
  
  'test if else conditional': ->
    tree = @parse '{if early}<div>good morning</div>{else}<div>good evening</div>{end}'
    nodes = tree.children
    
    @assertEqual 1, nodes.length
    node = nodes[0]
    @assertEqual 'conditional', node.type
    @assertEqual 'early', node.source
    
    @assertEqual 1, node.trueChildren.length
    @assertEqual 1, node.falseChildren.length
    
    div1 = node.trueChildren[0]
    @assertEqual 'element', div1.type
    @assertEqual 'div', div1.tag
    @assertEqual 'good morning', div1.children[0].value
    
    div1 = node.falseChildren[0]
    @assertEqual 'element', div1.type
    @assertEqual 'div', div1.tag
    @assertEqual 'good evening', div1.children[0].value
