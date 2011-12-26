Parser = require '../lib/rango/template/parser'
Janitor = require 'janitor'

module.exports = class extends Janitor.TestCase
  parse: (source) ->
    Parser.parse source

  'test empty tag': ->
    tree = @parse '<div></div>'

    @assert_equal 1, tree.children.length
    @assert_equal 'div', tree.children[0].tag
    @assert_equal 'element', tree.children[0].type
    @assert_equal undefined, tree.children[0].value
    @assert !tree.children[0].is_dynamic

  'test tag with static text': ->
    tree = @parse '<div>hi</div>'

    @assert_equal 1, tree.children.length
    @assert_equal 'div', tree.children[0].tag
    @assert_equal 'hi', tree.children[0].value.get()
    @assert !tree.children[0].is_dynamic

  'test multiple tags': ->
    tree = @parse '<div>one</div><span>two</span>'

    @assert_equal 2, tree.children.length

    first_element = tree.children[0]
    @assert_equal 'div', first_element.tag
    @assert_equal 'one', first_element.value.get()

    last_element = tree.children[1]
    @assert_equal 'span', last_element.tag
    @assert_equal 'two', last_element.value.get()
  
  'test nested tags': ->
    tree = @parse '<ol><li>One</li><li>Two</li></ol>'

    @assert_equal 1, tree.children.length

    first_element = tree.children[0]
    @assert_equal 'ol', first_element.tag

    for value, i in ['One', 'Two']
      element = first_element.children[i]
      @assert_equal 'li', element.tag
      @assert_equal value, element.value.get()
  
  'test tag with dynamic text': ->
    tree = @parse '<div>{greeting}</div>'

    @assert_equal 1, tree.children.length
    @assert_equal 'div', tree.children[0].tag
    @assert_equal 'greeting', tree.children[0].value.get()
    @assert tree.children[0].value.is_dynamic

  'test for token': ->
    tree = @parse '<ol>{for users}<li>{user}</li>{end}</ol>'

    @assert_equal 1, tree.children.length
    
    ol_node = tree.children[0]
    for_node = ol_node.children[0]
    @assert_equal 'for', for_node.type
    @assert_equal 'users', for_node.source
    
    li_elm = for_node.children[0]
    @assert_equal 'li', li_elm.tag
    @assert_equal 'user', li_elm.value.get()
    @assert li_elm.value.is_dynamic
  
  'test static style': ->
    tree = @parse '<div style="color: red">funky text</div>'

    @assert_equal 1, tree.children.length
    @assert tree.children[0].styles
    @assert_equal 'red', tree.children[0].styles.color.get()

  'test dynamic style': ->
    tree = @parse '<div style="color: {color}">funky text</div>'

    @assert_equal 1, tree.children.length
    @assert tree.children[0].styles
    @assert_equal 'color', tree.children[0].styles.color.get()
    @assert tree.children[0].styles.color.is_dynamic
