Janitor = require 'janitor'
Wingman = require '../../.'
View = Wingman.View
document = require('jsdom').jsdom()

module.exports = class extends Janitor.TestCase
  setup: ->
    Wingman.document = document
    View.template_sources = {}
  
  'test simple template': ->
    View.template_sources.simple = '<div>hello</div>'
    ViewKlass = class MainView extends View
      template_path: 'simple'
      
    view = new ViewKlass parent_el: document.createElement('div')
    @assert_equal 1, view.el.childNodes.length
    @assert_equal 'hello', view.el.childNodes[0].innerHTML

  'test simple template': ->
    View.template_sources.simple_with_dynamic_values = '<div>{myName}</div>'
    ViewKlass = class MainView extends View
      template_path: 'simple_with_dynamic_values'

    view = new ViewKlass parent_el: document.createElement('div')
    view.set myName: 'Razda'
    @assert_equal 1, view.el.childNodes.length
    @assert_equal 'Razda', view.el.childNodes[0].innerHTML
