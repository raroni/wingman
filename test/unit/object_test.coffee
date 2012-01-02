Janitor = require 'janitor'
Wingman = require '../..'

module.exports = class extends Janitor.TestCase
  'test simple set/get': ->
    klass = class extends Wingman.Object
    instance = new klass
    instance.set name: 'rasmus'
    @assert_equal 'rasmus', instance.get('name')
  
  'test get method property': ->
    Person = class extends Wingman.Object
      fullName: -> "#{@get('firstName')} #{@get('lastName')}"
    
    person = new Person
    person.set firstName: 'Rasmus', lastName: 'Nielsen'
    @assert_equal 'Rasmus Nielsen', person.get('fullName')
  
  'test observe': ->
    Person = class extends Wingman.Object
    person = new Person
    person.set name: 'Roger'

    new_name_from_callback = ''
    old_name_from_callback = ''
    person.observe 'name', (new_name, old_name) ->
      new_name_from_callback = new_name
      old_name_from_callback = old_name
    person.set name: 'Rasmus'
    @assert_equal new_name_from_callback, 'Rasmus'
    @assert_equal old_name_from_callback, 'Roger'


  'test unobserve': ->
    Person = class extends Wingman.Object
    person = new Person
    callback_run = false
    callback = ->
      callback_run = true
    person.observe 'name', callback
    person.unobserve 'name', callback
    person.set name: 'Rasmus'
    @assert !callback_run

  'test nested get': ->
    Car = class extends Wingman.Object
    CarType = class extends Wingman.Object
    
    slow_car = new CarType
    slow_car.set name: 'Toyota'
    car = new Car()
    car.set type: slow_car
    @assert_equal 'Toyota', car.get('type.name')
  
  'test nested observe': ->
    denmark = new Wingman.Object
    denmark.set name: 'Denmark'
    england = new Wingman.Object
    england.set name: 'England'
    sweden = new Wingman.Object
    sweden.set name: 'Sweden'
    region1 = new Wingman.Object
    region1.set {country: denmark}
    region2 = new Wingman.Object
    region2.set {country: sweden}
    city = new Wingman.Object
    city.set {region: region1}

    new_names = []
    old_names = []
    city.observe 'region.country.name', (new_name, old_name) ->
      new_names.push new_name
      old_names.push old_name

    denmark.set name: 'Denmark test'
    region1.set country: england
    denmark.set name: 'Denmark test2'
    city.set region: region2

    @assert_equal 3, new_names.length
    @assert_equal 'Denmark test', new_names[0]
    @assert_equal 'England', new_names[1]
    @assert_equal 'Sweden', new_names[2]

    @assert_equal 3, old_names.length
    @assert_equal 'Denmark', old_names[0]
    @assert_equal 'Denmark test', old_names[1]
    @assert_equal 'England', old_names[2]
  
  'test property dependencies': ->
    Person = class extends Wingman.Object
      @addPropertyDependencies
        fullName: ['firstName', 'lastName']
      
      fullName: -> "#{@get('firstName')} #{@get('lastName')}"

    person = new Person
    result = ''
    person.observe 'fullName', (new_value) -> result = new_value
    person.set firstName: 'Rasmus', lastName: 'Nielsen'

    @assert_equal result, 'Rasmus Nielsen'

  'test nested observe combined with property dependencies': ->
    Country = class extends Wingman.Object
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
    region1 = new Wingman.Object
    region1.set {country: denmark}
    region2 = new Wingman.Object
    region2.set {country: sweden}
    city = new Wingman.Object
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

  'test observe array property add': ->
    instance = new Wingman.Object
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

  'test observe array property remove': ->
    country = new Wingman.Object
    country.set cities: ['London', 'Manchester']
    removed_value_from_callback = ''
    country.observe 'cities', 'remove', (removed_value) -> removed_value_from_callback = removed_value
    country.get('cities').remove 'London'

    @assert_equal 'London', removed_value_from_callback
    @assert_equal 'Manchester', country.get('cities')[0]
    @assert_equal 1, country.get('cities').length

  'test observe nested array property': ->
      country = new Wingman.Object
      country.set cities: ['London', 'Manchester']
      user = new Wingman.Object
      user.set {country}
  
      result = ''
      user.observe 'country.cities', 'add', (new_value) -> result = new_value
      country.get('cities').push 'Liverpool'
  
      @assert_equal 'Liverpool', result
