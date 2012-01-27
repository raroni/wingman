Parser = require '../../../lib/wingman/template/parser'
Janitor = require 'janitor'

module.exports = class extends Janitor.TestCase
  parse: (source) ->
    Parser.parse source

  'test empty tag': ->
    tree = @parse '<div></div>'

    @assertEqual 1, tree.children.length
    @assertEqual 'div', tree.children[0].tag
    @assertEqual 'element', tree.children[0].type
    @assertEqual undefined, tree.children[0].value
    @assert !tree.children[0].is_dynamic

  'test empty tag with tag name containing numbers': ->
    tree = @parse '<h1></h1>'

    @assertEqual 1, tree.children.length
    @assertEqual 'h1', tree.children[0].tag

  'test tag with static text': ->
    tree = @parse '<div>hi</div>'

    @assertEqual 1, tree.children.length
    @assertEqual 'div', tree.children[0].tag
    @assertEqual 'hi', tree.children[0].value.get()
    @assert !tree.children[0].is_dynamic

  'test use of newlines and tabs': ->
    template_source = """
      <div>
        Raz to the mouse!
      </div>
    """

    tree = @parse template_source

    @assertEqual 1, tree.children.length
    @assertEqual 'div', tree.children[0].tag
    @assertEqual 'Raz to the mouse!', tree.children[0].value.get()
    @assert !tree.children[0].is_dynamic

  'test multiple tags': ->
    tree = @parse '<div>one</div><span>two</span>'

    @assertEqual 2, tree.children.length

    first_element = tree.children[0]
    @assertEqual 'div', first_element.tag
    @assertEqual 'one', first_element.value.get()

    last_element = tree.children[1]
    @assertEqual 'span', last_element.tag
    @assertEqual 'two', last_element.value.get()
  
  'test nested tags': ->
    tree = @parse '<ol><li>One</li><li>Two</li></ol>'

    @assertEqual 1, tree.children.length

    first_element = tree.children[0]
    @assertEqual 'ol', first_element.tag

    for value, i in ['One', 'Two']
      element = first_element.children[i]
      @assertEqual 'li', element.tag
      @assertEqual value, element.value.get()
  
  'test tag with dynamic text': ->
    tree = @parse '<div>{greeting}</div>'

    @assertEqual 1, tree.children.length
    @assertEqual 'div', tree.children[0].tag
    @assertEqual 'greeting', tree.children[0].value.get()
    @assert tree.children[0].value.is_dynamic

  'test for token': ->
    tree = @parse '<ol>{for users}<li>{user}</li>{end}</ol>'

    @assertEqual 1, tree.children.length
    
    ol_node = tree.children[0]
    for_node = ol_node.children[0]
    @assertEqual 'for', for_node.type
    @assertEqual 'users', for_node.source
    
    li_elm = for_node.children[0]
    @assertEqual 'li', li_elm.tag
    @assertEqual 'user', li_elm.value.get()
    @assert li_elm.value.is_dynamic
  
  'test element with single static style': ->
    tree = @parse '<div style="color: red">funky text</div>'

    @assertEqual 1, tree.children.length
    @assert tree.children[0].styles
    @assertEqual 'red', tree.children[0].styles.color.get()

  'test element with single dynamic style': ->
    tree = @parse '<div style="color: {color}">funky text</div>'

    @assertEqual 1, tree.children.length
    @assert tree.children[0].styles
    @assertEqual 'color', tree.children[0].styles.color.get()
    @assert tree.children[0].styles.color.is_dynamic
  
  'test element with several static styles': ->
    tree = @parse '<div style="color: blue; font-size: 14px">funky text</div>'

    @assertEqual 1, tree.children.length
    element = tree.children[0]
    @assert element.styles
    @assertEqual 'blue', element.styles.color.get()
    @assertEqual '14px', element.styles['font-size'].get()

  'test element with static and dynamic styles': ->
    tree = @parse '<div style="color: blue; font-size: {someFontSize}">funky text</div>'

    @assertEqual 1, tree.children.length
    styles = tree.children[0].styles
    @assert styles
    @assertEqual 'blue', styles.color.get()
    @assert !styles.color.is_dynamic
    @assertEqual 'someFontSize', styles['font-size'].get()
    @assert styles['font-size'].is_dynamic
  
  'test element with single static class': ->
    tree = @parse '<div class="funny_class">funky text</div>'
    classes = tree.children[0].classes
    @assert classes
    @assertEqual 1, classes.length
    @assertEqual 'funny_class', classes[0].get()
    @assert !classes[0].is_dynamic

  'test element with two static classes': ->
    tree = @parse '<div class="funny_class another_funny_class">funky text</div>'
    classes = tree.children[0].classes
    @assert classes
    @assertEqual 2, classes.length
    @assertEqual 'funny_class', classes[0].get()
    @assertEqual 'another_funny_class', classes[1].get()
    @assert !klass.is_dynamic for klass in classes

  'test element with single dynamic class': ->
    tree = @parse '<div class="{funny_class}">funky text</div>'
    classes = tree.children[0].classes
    @assert classes
    @assertEqual 1, classes.length
    @assertEqual 'funny_class', classes[0].get()
    @assert classes[0].is_dynamic
    
  'test element with two dynamic classes': ->
    tree = @parse '<div class="{funny_class} {another_funny_class}">funky text</div>'
    classes = tree.children[0].classes
    @assert classes
    @assertEqual 2, classes.length
    @assertEqual 'funny_class', classes[0].get()
    @assertEqual 'another_funny_class', classes[1].get()
    @assert klass.is_dynamic for klass in classes

  'test non closing tag': ->
    tree = @parse '<div><input></div><div>something else</div>'

    divs = tree.children
    @assertEqual 2, divs.length
    @assertEqual 1, divs[0].children.length
    
    input = divs[0].children[0]
    @assertEqual 'element', input.type
    @assertEqual 'input', input.tag

  'test tag combined with sub view': ->
    tree = @parse '<h1>Some title</h1>{view user}'

    nodes = tree.children
    @assertEqual 2, nodes.length
    
    sub_view_node = nodes[1]
    
    @assertEqual 'sub_view', sub_view_node.type
    @assertEqual 'user', sub_view_node.name
