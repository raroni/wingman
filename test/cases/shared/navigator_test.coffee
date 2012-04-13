Janitor = require 'janitor'
WingmanObject = require '../../../lib/wingman/shared/object'
Module = require '../../../lib/wingman/shared/module'
Navigator = require '../../../lib/wingman/shared/navigator'
Wingman = require '../../../.'
JSDomWindowPopStateDecorator = require '../../jsdom_window_pop_state_decorator'
jsdom = require 'jsdom'

class DummyController extends Module
  @include Navigator

module.exports = class NavigatorTest extends Janitor.TestCase
  setup: ->
    Wingman.document = jsdom.jsdom()
    Wingman.window = JSDomWindowPopStateDecorator.create(Wingman.document.createWindow())
    @controller = new DummyController
  
  teardown: ->
    delete Wingman.document
    delete Wingman.window
  
  'test simple navigate': ->
    @controller.navigate 'something'
    @assertEqual '/something', Wingman.document.location.pathname
  
  'test navigation options': ->
    @controller.navigate 'something', something: 'yeah'
    @assertEqual '/something', Wingman.document.location.pathname
    entries = Wingman.window.history.entries
    @assertEqual 'yeah', entries[entries.length-1].state.something
  
  'test back': ->
    @controller.navigate 'first_page'
    @controller.navigate 'second_page'
    @controller.back()
    @assertEqual '/first_page', Wingman.document.location.pathname
  
  'test go': ->
    @controller.navigate 'first_page'
    @controller.navigate 'second_page'
    @controller.navigate 'third_page'
    @controller.back 2
    @assertEqual '/first_page', Wingman.document.location.pathname
