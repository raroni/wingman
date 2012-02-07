document = require('jsdom').jsdom()
Janitor = require 'janitor'
Elementary = require '../../../lib/wingman-client/shared/elementary'
Module = require '../../../lib/wingman-client/shared/module'

DummyObject = class extends Module
  @include Elementary
  constructor: ->
    @dom_element = document.createElement 'div'

module.exports = class extends Janitor.TestCase
  setup: ->
    @dummy_object = new DummyObject
  
  'test css property name convertion from dom to css notation': ->
    @assertEqual 'fontSize', Elementary.convertCssPropertyFromDomToCssNotation 'font-size'
    @assertEqual 'marginTop', Elementary.convertCssPropertyFromDomToCssNotation 'margin-top'
    @assertEqual 'borderTopColor', Elementary.convertCssPropertyFromDomToCssNotation 'border-top-color'
  
  'test setting a style': ->
    @dummy_object.setStyle 'color', 'red'
    @assertEqual 'red', @dummy_object.dom_element.style.color
  
  'test adding two identical classes': ->
    @dummy_object.addClass 'user' for [1..2]
    @assertEqual 'user', @dummy_object.dom_element.className
  
  'test setting attribute': ->
    @dummy_object.setAttribute 'name', 'rasmus'
    @assertEqual 'rasmus', @dummy_object.dom_element.getAttribute('name')
