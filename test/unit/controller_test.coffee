Janitor = require 'janitor'
Wingman = require '../../.'
Wingman.document = require('jsdom').jsdom()

module.exports = class extends Janitor.TestCase
  'test automatic children instantiation': ->
    Wingman.View.template_sources = {
      'user': '<div>stubbing the source</div>'
    }
    
    MainController = class extends Wingman.Controller
    MainController.UserController = class extends Wingman.Controller
    MainController.UserView = class extends Wingman.View
    
    root_el = Wingman.document.createElement 'div'
    controller = new MainController el: root_el
    
    @assert root_el.innerHTML.match('stubbing the source')
