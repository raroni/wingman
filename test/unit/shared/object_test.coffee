Janitor = require 'janitor'
WingmanObject = require '../../../lib/wingman/shared/object'

module.exports = class extends Janitor.TestCase
  'test simple set/get': ->
    klass = class extends WingmanObject
    instance = new klass
    instance.set name: 'rasmus'
    @assertEqual 'rasmus', instance.get('name')
  
  'test get method property': ->
    Person = class extends WingmanObject
      fullName: -> "#{@get('firstName')} #{@get('lastName')}"
    
    person = new Person
    person.set firstName: 'Rasmus', lastName: 'Nielsen'
    @assertEqual 'Rasmus Nielsen', person.get('fullName')
  
  'test observe': ->
    Person = class extends WingmanObject
    person = new Person
    person.set name: 'Roger'

    new_name_from_callback = ''
    old_name_from_callback = ''
    person.observe 'name', (new_name, old_name) ->
      new_name_from_callback = new_name
      old_name_from_callback = old_name
    person.set name: 'Rasmus'
    @assertEqual new_name_from_callback, 'Rasmus'
    @assertEqual old_name_from_callback, 'Roger'


  'test unobserve': ->
    Person = class extends WingmanObject
    person = new Person
    callback_run = false
    callback = ->
      callback_run = true
    person.observe 'name', callback
    person.unobserve 'name', callback
    person.set name: 'Rasmus'
    @assert !callback_run

  'test nested get': ->
    Car = class extends WingmanObject
    CarType = class extends WingmanObject
    
    slow_car = new CarType
    slow_car.set name: 'Toyota'
    car = new Car()
    car.set type: slow_car
    @assertEqual 'Toyota', car.get('type.name')
  
  'test nested observe': ->
    denmark = new WingmanObject
    denmark.set name: 'Denmark'
    england = new WingmanObject
    england.set name: 'England'
    sweden = new WingmanObject
    sweden.set name: 'Sweden'
    region1 = new WingmanObject
    region1.set {country: denmark}
    region2 = new WingmanObject
    region2.set {country: sweden}
    city = new WingmanObject
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

    @assertEqual 3, new_names.length
    @assertEqual 'Denmark test', new_names[0]
    @assertEqual 'England', new_names[1]
    @assertEqual 'Sweden', new_names[2]

    @assertEqual 3, old_names.length
    @assertEqual 'Denmark', old_names[0]
    @assertEqual 'Denmark test', old_names[1]
    @assertEqual 'England', old_names[2]
  
  'test property dependencies': ->
    Person = class extends WingmanObject
      @addPropertyDependencies
        fullName: ['firstName', 'lastName']
      
      fullName: -> "#{@get('firstName')} #{@get('lastName')}"

    person = new Person
    result = ''
    person.observe 'fullName', (new_value) -> result = new_value
    person.set firstName: 'Rasmus', lastName: 'Nielsen'

    @assertEqual result, 'Rasmus Nielsen'

  'test nested observe combined with property dependencies': ->
    Country = class extends WingmanObject
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
    region1 = new WingmanObject
    region1.set {country: denmark}
    region2 = new WingmanObject
    region2.set {country: sweden}
    city = new WingmanObject
    city.set {region: region1}

    names = []
    city.observe 'region.country.name', (new_name) -> names.push(new_name)
    denmark.set code: 'SE'
    region1.set country: england
    denmark.set code: 'UK'
    city.set region: region2

    @assertEqual 3, names.length
    @assertEqual 'Sweden', names[0]
    @assertEqual 'England', names[1]
    @assertEqual 'Sweden', names[2]

  'test observe array property add': ->
    instance = new WingmanObject
    added = []
    instance.observe 'users', 'add', (new_value) -> added.push(new_value)
    instance.set users: []
    instance.get('users').push 'Rasmus'
    instance.get('users').push 'John'
    instance.set users: []
    instance.get('users').push 'Jack'

    @assertEqual 'Rasmus', added[0]
    @assertEqual 'John', added[1]
    @assertEqual 'Jack', added[2]
    @assertEqual 1, instance.get('users').length

  'test observe array property remove': ->
    country = new WingmanObject
    country.set cities: ['London', 'Manchester']
    removed_value_from_callback = ''
    country.observe 'cities', 'remove', (removed_value) -> removed_value_from_callback = removed_value
    country.get('cities').remove 'London'

    @assertEqual 'London', removed_value_from_callback
    @assertEqual 'Manchester', country.get('cities')[0]
    @assertEqual 1, country.get('cities').length

  'test observe nested array property': ->
    country = new WingmanObject
    country.set cities: ['London', 'Manchester']
    user = new WingmanObject
    user.set {country}

    result = ''
    user.observe 'country.cities', 'add', (new_value) -> result = new_value
    country.get('cities').push 'Liverpool'

    @assertEqual 'Liverpool', result

  'test export to JSON': ->
    Country = class extends WingmanObject
      name: -> 'method properties should not be a part of toJSON'
      otherProperty: => 'not even if you bind them like this'
        
    country = new Country
    country.set code: 'dk', region: 'eu'
    
    @assertEqual 'dk', country.toJSON().code
    @assertEqual 'eu', country.toJSON().region
    @assertEqual 2, Object.keys(country.toJSON()).length

  'test export to JSON with only options': ->
    country = new WingmanObject
    country.set code: 'dk', region: 'eu', population: 5000000

    only_code = country.toJSON(only: 'code')

    @assertEqual 'dk', only_code.code
    @assertEqual 1, Object.keys(only_code).length
    
    only_code_and_region = country.toJSON(only: ['code', 'region'])

    @assertEqual 'dk', only_code.code
    @assertEqual 'eu', country.toJSON().region
    @assertEqual 2, Object.keys(only_code_and_region).length
  
  'test nested set': ->
    context = new WingmanObject
    context.set
      user:
        name: 'Rasmus'
        age: 25
    
    @assertEqual 'Rasmus', context.get('user.name')
    @assertEqual 25, context.get('user.age')

  'test nested set with arrays': ->
    context = new WingmanObject
    context.set
      name: 'Rasmus'
      age: 25
      friends: [
        { name: 'Marcus', age: 26 }
        { name: 'John', age: 27 }
      ]

    @assertEqual 'Marcus', context.get('friends')[0].get('name')
    @assertEqual 26, context.get('friends')[0].get('age')
    @assertEqual 'John', context.get('friends')[1].get('name')
    @assertEqual 27, context.get('friends')[1].get('age')
