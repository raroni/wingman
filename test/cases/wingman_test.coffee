Janitor = require 'janitor'
Wingman = require '../../.'

module.exports = class WingmanTest extends Janitor.TestCase
  'test exports': ->
    @assert Wingman.request
    @assert Wingman.Template
    @assert Wingman.View
    @assert Wingman.Model
    @assert Wingman.Controller
    @assert Wingman.Application
    @assert Wingman.Module
    @assert Wingman.Events
    @assertEqual Wingman.store().constructor, Wingman.Store
  
  'test store singleton': ->
    @assertEqual Wingman.store(), Wingman.store()
