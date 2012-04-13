jsdom = require 'jsdom'
Janitor = require 'janitor'
ConditionalHandler = require '../../../../lib/wingman/template/handler_factory/conditional_handler'
Wingman = require '../../../../.'
WingmanObject = require '../../../../lib/wingman/shared/object'

module.exports = class ConditionalHandlerTest extends Janitor.TestCase
  setup: ->
    Wingman.document = jsdom.jsdom()
    @parent = Wingman.document.createElement 'div'
  
  teardown: ->
    delete Wingman.document
  
  'test simple conditional': ->
    options =
      scope: @parent
      type: 'conditional'
      source: 'something'
      trueChildren: [
        {
          type: 'element'
          tag: 'span'
          children: [
            type: 'text'
            value: 'user'
          ]
        }
        {
          type: 'element'
          tag: 'span'
          children: [
            type: 'text'
            value: 'user2'
          ]
        }
      ]
    
    context = new WingmanObject
    context.set something: true
    new ConditionalHandler options, context
    
    childNodes = @parent.childNodes
    @assertEqual 2, childNodes.length
    @assertEqual 'user', childNodes[0].innerHTML
    @assertEqual 'user2', childNodes[1].innerHTML
    context.set something: false
    @assertEqual 0, childNodes.length
  
  'test if else conditonal': ->
    options =
      type: 'conditional'
      source: 'early'
      scope: @parent
      trueChildren: [
        {
          type: 'element'
          tag: 'span'
          children: [
            type: 'text'
            value: 'good morning'
          ]
        }
        {
          type: 'element'
          tag: 'span'
          children: [
            type: 'text'
            value: 'good morning again'
          ]
        }
      ]
      falseChildren: [
        type: 'element'
        tag: 'span'
        children: [
          type: 'text'
          value: 'good evening'
        ]
      ]
    
    context = new WingmanObject
    context.set early: true
    new ConditionalHandler options, context
    
    childNodes = @parent.childNodes
    @assertEqual 2, childNodes.length
    @assertEqual 'good morning', childNodes[0].innerHTML
    @assertEqual 'good morning again', childNodes[1].innerHTML
    context.set early: false
    @assertEqual 1, childNodes.length
    @assertEqual 'good evening', childNodes[0].innerHTML
