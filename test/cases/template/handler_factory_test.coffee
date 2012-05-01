Janitor = require 'janitor'
HandlerFactory = require '../../../lib/wingman/template/handler_factory'
Wingman = require '../../..'
CustomAssertions = require '../../custom_assertions'
jsdom = require 'jsdom'

module.exports = class HandlerFactoryTest extends Janitor.TestCase
  setup: ->
    Wingman.document = jsdom.jsdom()
    @parent = Wingman.document.createElement 'div'
  
  teardown: ->
    delete Wingman.document
  
  assertDOMElementHasClass: CustomAssertions.assertDOMElementHasClass
  refuteDOMElementHasClass: CustomAssertions.refuteDOMElementHasClass
  
  'test simple element node': ->
    options =
      type: 'element'
      tag: 'div'
      scope: @parent
      children: [
        type: 'text'
        value: 'test'
      ]
    
    HandlerFactory.create options
    element = @parent.childNodes[0]
    @assert element
    @assertEqual 'DIV', element.tagName
    @assertEqual @parent, element.parentNode
  
  # TODO: Comment this out when ForHandler is converted to use new Wingman.Object
  #'test for with deferred push': ->
  #  element = Wingman.document.createElement 'ol'
  #  options =
  #    type: 'for'
  #    source: 'users'
  #    scope: element
  #    children: [
  #      type: 'element'
  #      tag: 'li'
  #      source: 'user'
  #    ]
  #  
  #  context = Wingman.Object.create users: ['Rasmus', 'John']
  #  HandlerFactory.create options, context
  #  
  #  @assertEqual 2, element.childNodes.length
  #  context.users.push 'Joe'
  #  @assertEqual 3, element.childNodes.length
  #  @assertEqual 'Joe', element.childNodes[2].innerHTML
