document = require('jsdom').jsdom()
Janitor = require 'janitor'
Conditional = require '../../../../lib/wingman-client/template/node_interpreter/conditional'
Wingman = require '../../../../.'
Value = require '../../../../lib/wingman-client/template/parser/value'
WingmanObject = require '../../../../lib/wingman-client/shared/object'

module.exports = class ConditionalTest extends Janitor.TestCase
  setup: ->
    Wingman.document = document
    @parent = Wingman.document.createElement 'div'

  'test simple conditional': ->
    node_data =
      type: 'conditional'
      source: 'something'
      children: [
        type: 'element'
        tag: 'span'
        value: new Value('user')
      ]
    
    context = new WingmanObject
    context.set something: true
    new Conditional node_data, @parent, context
    
    element = @parent.childNodes[0]
    @assert !element.style.display
    
    context.set something: false
    @assertEqual 'none', element.style.display
