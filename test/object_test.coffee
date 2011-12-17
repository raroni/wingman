Janitor = require 'janitor'
Rango = require '../rango'

module.exports = class extends Janitor.TestCase
  'test simple set/get': ->
    klass = class extends Rango.Object
    instance = new klass
    instance.set name: 'rasmus'
    @assert_equal 'rasmus', instance.get('name')
  
  'test get method property': ->
    Person = class extends Rango.Object
      fullName: -> "#{@get('firstName')} #{@get('lastName')}"
    
    person = new Person
    person.set firstName: 'Rasmus', lastName: 'Nielsen'
    @assert_equal 'Rasmus Nielsen', person.get('fullName')
  
  'test change property event': ->
    Person = class extends Rango.Object
    person = new Person
    triggered = false
    person.observe 'name', -> triggered = true
    person.set name: 'Rasmus'
    @assert triggered
