document = require('jsdom').jsdom()
Janitor = require 'janitor'
Elementary = require '../../../lib/wingman/shared/elementary'
Module = require '../../../lib/wingman/shared/module'

DummyObject = class extends Module
  @include Elementary
  constructor: ->
    @domElement = document.createElement 'div'

module.exports = class extends Janitor.TestCase
  setup: ->
    @dummyObject = new DummyObject
  
  'test css property name convertion from dom to css notation': ->
    @assertEqual 'fontSize', Elementary.convertCssPropertyFromDomToCssNotation 'font-size'
    @assertEqual 'marginTop', Elementary.convertCssPropertyFromDomToCssNotation 'margin-top'
    @assertEqual 'borderTopColor', Elementary.convertCssPropertyFromDomToCssNotation 'border-top-color'
  
  'test setting a style': ->
    @dummyObject.setStyle 'color', 'red'
    @assertEqual 'red', @dummyObject.domElement.style.color
  
  'test adding two identical classes': ->
    @dummyObject.addClass 'user' for [1..2]
    @assertEqual 'user', @dummyObject.domElement.className
  
  'test setting attribute': ->
    @dummyObject.setAttribute 'name', 'rasmus'
    @assertEqual 'rasmus', @dummyObject.domElement.getAttribute('name')
