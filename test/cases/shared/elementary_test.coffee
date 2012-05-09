document = require('jsdom').jsdom()
Janitor = require 'janitor'
Elementary = require '../../../lib/wingman/shared/elementary'
WingmanObject = require '../../../lib/wingman/shared/object'

DummyObject = WingmanObject.extend
  initialize: ->
    @el = document.createElement 'div'

DummyObject.prototype.include Elementary

module.exports = class extends Janitor.TestCase
  setup: ->
    @dummyObject = DummyObject.create()
  
  'test css property name convertion from dom to css notation': ->
    @assertEqual 'fontSize', Elementary.convertCssPropertyFromDomToCssNotation 'font-size'
    @assertEqual 'marginTop', Elementary.convertCssPropertyFromDomToCssNotation 'margin-top'
    @assertEqual 'borderTopColor', Elementary.convertCssPropertyFromDomToCssNotation 'border-top-color'
  
  'test setting a style': ->
    @dummyObject.setStyle 'color', 'red'
    @assertEqual 'red', @dummyObject.el.style.color
  
  'test adding two identical classes': ->
    @dummyObject.addClass 'user' for [1..2]
    @assertEqual 'user', @dummyObject.el.className
  
  'test setting attribute': ->
    @dummyObject.setAttribute 'name', 'rasmus'
    @assertEqual 'rasmus', @dummyObject.el.getAttribute('name')
