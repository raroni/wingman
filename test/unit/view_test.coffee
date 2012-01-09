Janitor = require 'janitor'
Wingman = require '../../.'
View = Wingman.View
document = require('jsdom').jsdom(null, null, features: {
        QuerySelector : true
      })

clickElement = (elm) ->
  event = document.createEvent "MouseEvents"
  event.initMouseEvent "click", true, true
  elm.dispatchEvent event

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
  
  'test parse events': ->
    events_hash =
      'click .user': 'user_clicked'
      'hover button.some_class': 'button_hovered'
      
    events = View.parseEvents(events_hash).sort (e1, e2) -> e1.type > e2.type
    
    @assert_equal 'click', events[0].type
    @assert_equal 'user_clicked', events[0].trigger
    @assert_equal '.user', events[0].selector
    
    @assert_equal 'hover', events[1].type
    @assert_equal 'button_hovered', events[1].trigger
    @assert_equal 'button.some_class', events[1].selector
  
  'test simple event': ->
    View.template_sources.test = '<div><div class="user">Johnny</div></div>'
    ViewKlass = class MainView extends View
      template_path: 'test'
      events:
        'click .user': 'user_clicked'
    
    view = new ViewKlass parent_el: document.createElement('div')
    clicked = false
    view.bind 'user_clicked', ->
      clicked = true
    
    clickElement view.el.childNodes[0].childNodes[0]
    @assert clicked

  'test trigger arguments': ->
    View.template_sources.test = '<div>Something</div>'
    ViewKlass = class MainView extends View
      template_path: 'test'
      events:
        'click div': 'something_happened'
      
      somethingHappenedArguments: ->
        ['a', 'b']

    view = new ViewKlass parent_el: document.createElement('div')
    a = null
    b = null
    view.bind 'something_happened', (x,y) ->
      a = x
      b = y

    clickElement view.el.childNodes[0]
    @assert_equal 'a', a
    @assert_equal 'b', b
