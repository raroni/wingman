Parser = require '../lib/template/parser'
Janitor = require 'janitor'

module.exports = class extends Janitor.TestCase
  parse: (source) ->
    Parser.parse source

  'test empty tag': ->
    tree = @parse '<div></div>'

    @assert_equal 1, tree.children.length
    @assert_equal 'div', tree.children[0].tag
    @assert_equal undefined, tree.children[0].inner_html

  'test tag with static text': ->
    tree = @parse '<div>hi</div>'

    @assert_equal 1, tree.children.length
    @assert_equal 'div', tree.children[0].tag
    @assert_equal 'hi', tree.children[0].inner_html
