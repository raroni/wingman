document = require('jsdom').jsdom()
Janitor = require 'janitor'
ChildView = require '../../../../lib/wingman-client/template/node_interpreter/child_view'
Wingman = require '../../../../.'

module.exports = class ForBlockTest extends Janitor.TestCase
  setup: ->
    Wingman.document = document
    @parent = Wingman.document.createElement 'div'
    
  'test simple child view': ->
    element_node =
      type: 'child_view'
      name: 'user'

    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: -> '<div>I am the user view</div>'

    main_view = new MainView
    new ChildView element_node, @parent, main_view
    @assertEqual '<div>I am the user view</div>', @parent.childNodes[0].innerHTML
  
  'test activate and deactivate': ->
    element_node =
      type: 'child_view'
      name: 'user'

    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: -> '<div>I am the user view</div>'

    main_view = new MainView
    child_view = new ChildView element_node, @parent, main_view
    child_view.deactivate()
    
    @assertEqual 'none', @parent.childNodes[0].style.display
    
    child_view.activate()
    @assert !@parent.childNodes[0].style.display
