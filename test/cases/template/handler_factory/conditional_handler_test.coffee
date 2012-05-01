jsdom = require 'jsdom'
Janitor = require 'janitor'
ConditionalHandler = require '../../../../lib/wingman/template/handler_factory/conditional_handler'
Wingman = require '../../../../.'

module.exports = class ConditionalHandlerTest extends Janitor.TestCase
  @solo: true
  
  setup: ->
    Wingman.document = jsdom.jsdom()
    @parent = Wingman.document.createElement 'div'
  
  teardown: ->
    delete Wingman.document
  
  'test simple conditional': ->
    options =
      scope: @parent
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
    
    context = Wingman.Object.create something: true
    ConditionalHandler.create { options, context }
    
    childNodes = @parent.childNodes
    @assertEqual 2, childNodes.length
    @assertEqual 'user', childNodes[0].innerHTML
    @assertEqual 'user2', childNodes[1].innerHTML
    context.something = false
    @assertEqual 0, childNodes.length
  
  'test if else conditonal': ->
    options =
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
    
    context = Wingman.Object.create early: true
    ConditionalHandler.create { options, context }
    
    childNodes = @parent.childNodes
    @assertEqual 2, childNodes.length
    @assertEqual 'good morning', childNodes[0].innerHTML
    @assertEqual 'good morning again', childNodes[1].innerHTML
    context.early = false
    @assertEqual 1, childNodes.length
    @assertEqual 'good evening', childNodes[0].innerHTML
