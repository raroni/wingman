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

  buildElement: (element_data, context, parent) ->
    element = document.createElement element_data.tag
    parent.appendChild element if parent
    if element_data.value
      element.innerHTML = if element_data.value.is_dynamic
        context.observe element_data.value.get(), (new_value) ->
          element.innerHTML = new_value
        context.get element_data.value.get()
      else
        element_data.value.get()
    else if element_data.children
      for child in element_data.children
        @buildElement child, context, element
    
    element
