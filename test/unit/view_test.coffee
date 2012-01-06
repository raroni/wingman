Janitor = require 'janitor'
Wingman = require '../../.'
View = Wingman.View
document = require('jsdom').jsdom()

templates = {
  simple: '<div>hello</div>'
}

module.exports = class extends Janitor.TestCase
  setup: ->
    Wingman.document = document
    View.templates = templates
  
  'test use template': ->
    ViewKlass = class MainView extends View
      template_path: 'simple'
      
    view = new ViewKlass parent_el: document.createElement('div')
    @assert_equal 1, view.el.childNodes.length
    @assert_equal 'hello', view.el.childNodes[0].innerHTML
