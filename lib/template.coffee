Parser = require './template/parser'

unless window?
  jsdom = require('jsdom').jsdom
  document = jsdom()

module.exports = class
  @compile = (source) ->
    template = new @ source
    (context) ->
      template.evaluate context
  
  constructor: (source) ->
    @tree = Parser.parse source

  evaluate: (context) ->
    (@buildElement(element_data, context) for element_data in @tree.children)

  buildElement: (element_data, context) ->
    element = document.createElement element_data.tag
    element.innerHTML = if element_data.value.is_dynamic
      context.get(element_data.value.get())
    else
      element_data.value.get()
    element
