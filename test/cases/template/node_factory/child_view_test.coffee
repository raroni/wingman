document = require('jsdom').jsdom()
Janitor = require 'janitor'
ChildView = require '../../../../lib/wingman-client/template/node_factory/child_view'
Wingman = require '../../../../.'

module.exports = class ForBlockTest extends Janitor.TestCase
  setup: ->
    Wingman.document = document
    @parent = Wingman.document.createElement 'div'
    
  'test simple child view': ->
    elementNode =
      type: 'childView'
      name: 'user'

    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: -> '<div>I am the user view</div>'

    mainView = new MainView
    new ChildView elementNode, @parent, mainView
    @assertEqual '<div>I am the user view</div>', @parent.childNodes[0].innerHTML
  
  'test remove': ->
    elementNode =
      type: 'childView'
      name: 'user'
    
    class MainView extends Wingman.View
    class MainView.UserView extends Wingman.View
      templateSource: -> '<div>I am the user view</div>'
    
    mainView = new MainView
    childView = new ChildView elementNode, @parent, mainView
    
    @assertEqual 1, @parent.childNodes.length
    
    childView.remove()
    @assertEqual 0, @parent.childNodes.length
