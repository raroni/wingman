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
  
  'test observe': ->
    Person = class extends Rango.Object
    person = new Person
    name_from_callback = ''
    person.observe 'name', (new_name) ->
      name_from_callback = new_name
    person.set name: 'Rasmus'
    @assert_equal name_from_callback, 'Rasmus'

  'test unobserve': ->
    Person = class extends Rango.Object
    person = new Person
    callback_run = false
    callback = ->
      callback_run = true
    person.observe 'name', callback
    person.unobserve 'name', callback
    person.set name: 'Rasmus'
    @assert !callback_run

  'test nested get': ->
    Car = class extends Rango.Object
    CarType = class extends Rango.Object
    
    slow_car = new CarType
    slow_car.set name: 'Toyota'
    car = new Car()
    car.set type: slow_car
    @assert_equal 'Toyota', car.get('type.name')
  
  'test nested observe': ->
    denmark = new Rango.Object
    denmark.set name: 'Denmark'
    england = new Rango.Object
    england.set name: 'England'
    sweden = new Rango.Object
    sweden.set name: 'Sweden'
    region1 = new Rango.Object
    region1.set {country: denmark}
    region2 = new Rango.Object
    region2.set {country: sweden}
    city = new Rango.Object
    city.set {region: region1}

    names = []
    city.observe 'region.country.name', (new_name) -> names.push(new_name)
    denmark.set name: 'Denmark test'
    region1.set country: england
    denmark.set name: 'Denmark test2'
    city.set region: region2

    @assert_equal 3, names.length
    @assert_equal 'Denmark test', names[0]
    @assert_equal 'England', names[1]
    @assert_equal 'Sweden', names[2]

  'test property dependencies': ->
    Person = class extends Rango.Object
      @addPropertyDependencies
        fullName: ['firstName', 'lastName']
      
      fullName: -> "#{@get('firstName')} #{@get('lastName')}"

    person = new Person
    result = ''
    person.observe 'fullName', (new_value) -> result = new_value
    person.set firstName: 'Rasmus', lastName: 'Nielsen'

    @assert_equal result, 'Rasmus Nielsen'

  'test nested observe combined with property dependencies': ->
    Country = class extends Rango.Object
      @CODES = 
        DK: 'Denmark'
        UK: 'England'
        SE: 'Sweden'

      @addPropertyDependencies
        name: ['code']

      name: ->
        @constructor.CODES[@get('code')]

    denmark = new Country
    denmark.set code: 'DK'
    england = new Country
    england.set code: 'UK'
    sweden = new Country
    sweden.set code: 'SE'
    region1 = new Rango.Object
    region1.set {country: denmark}
    region2 = new Rango.Object
    region2.set {country: sweden}
    city = new Rango.Object
    city.set {region: region1}

    names = []
    city.observe 'region.country.name', (new_name) -> names.push(new_name)
    denmark.set code: 'SE'
    region1.set country: england
    denmark.set code: 'UK'
    city.set region: region2

    @assert_equal 3, names.length
    @assert_equal 'Sweden', names[0]
    @assert_equal 'England', names[1]
    @assert_equal 'Sweden', names[2]

  'test observe array property': ->
    instance = new Rango.Object
    added = []
    instance.observe 'users', 'add', (new_value) -> added.push(new_value)
    instance.set users: []
    instance.get('users').push 'Rasmus'
    instance.get('users').push 'John'
    instance.set users: []
    instance.get('users').push 'Jack'

    @assert_equal 'Rasmus', added[0]
    @assert_equal 'John', added[1]
    @assert_equal 'Jack', added[2]
    @assert_equal 1, instance.get('users').length

  'test observe nested array property': ->
      country = new Rango.Object
      country.set cities: ['London', 'Manchester']
      user = new Rango.Object
      user.set {country}
  
      result = ''
      user.observe 'country.cities', 'add', (new_value) -> result = new_value
      country.get('cities').push 'Liverpool'
  
      @assert_equal 'Liverpool', result
