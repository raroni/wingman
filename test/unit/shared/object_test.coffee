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
  
  'test observe of unset properties': ->
    Person = class extends WingmanObject
    person = new Person
  
    new_name_from_callback = ''
    old_name_from_callback = ''
    person.observe 'name', (new_name, old_name) ->
      new_name_from_callback = new_name
      old_name_from_callback = old_name
    person.set name: 'Rasmus'
    @assertEqual new_name_from_callback, 'Rasmus'
    @assertEqual old_name_from_callback, undefined
  
  'test observe of nested unset properties': ->
    Person = class extends WingmanObject
    rasmus = new Person
    john = new Person
    john.set name: 'John'
  
    new_name_from_callback = ''
    old_name_from_callback = ''
    
    rasmus.observe 'friend.name', (new_name, old_name) ->
      new_name_from_callback = new_name
      old_name_from_callback = old_name
    rasmus.set friend: john
    
    @assertEqual new_name_from_callback, 'John'
    @assertEqual old_name_from_callback, undefined
  
  'test observing on deeply nested properties that are later changed': ->
    view = new WingmanObject
    latest_value_from_callback = undefined
    view.observe 'user.car.kilometers_driven', (new_value) -> latest_value_from_callback = new_value
  
    user = new WingmanObject
    view.set { user }
    car1 = new WingmanObject
    car1.set kilometers_driven: 200000
    car2 = new WingmanObject
    car2.set kilometers_driven: 10000
    
    user.set car: car1
    user.set car: car2
    
    @assertEqual 10000, latest_value_from_callback
  
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
  
  'test getting non existing nested property': ->
    Person = class extends WingmanObject
    person = new Person
    @assertEqual undefined, person.get 'this.does.not.exist'
  
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
      property_dependencies:
        fullName: ['firstName', 'lastName']
      
      fullName: -> "#{@get('firstName')} #{@get('lastName')}"
    
    person = new Person
    result = ''
    person.observe 'fullName', (new_value) -> result = new_value
    person.set firstName: 'Rasmus', lastName: 'Nielsen'
    
    @assertEqual 'Rasmus Nielsen', result
    
  'test property dependencies with single depending property': ->
    Country = class extends WingmanObject
      @NAMES: { dk: 'Denmark', se: 'Sweden' }
      
      property_dependencies:
        countryName: 'country_code'

      countryName: -> @constructor.NAMES[@get('country_code')]

    country = new Country
    result = undefined
    country.observe 'countryName', (new_value) -> result = new_value
    country.set country_code: 'dk'

    @assertEqual 'Denmark', result
  
  'test nested property dependencies': ->
    session = new WingmanObject
    View = class extends WingmanObject
      property_dependencies:
        isActive: 'session.user_id'
      
      isActive: ->
        !!@get('session.user_id')
    
    view = new View
    callback_fired = false
    view.observe 'isActive', -> callback_fired = true
    view.set {session}
    session.set user_id: 2
    @assert callback_fired
  
  'test several nested property dependencies': ->
    session = new WingmanObject
    session.set user_id: 1
    
    View = class extends WingmanObject
      property_dependencies:
        isActive: ['session.user_id']
        canTrain: ['training.created_on']
      
      canTrain: ->
        @get('training.created_on') != '2012-01-26'
      
      isActive: ->
        !!@get('session.user_id')
    
    view = new View
    is_active_callback_fired = false
    can_train_callback_fired = false
    view.observe 'isActive', -> is_active_callback_fired = true
    view.observe 'canTrain', -> can_train_callback_fired = true
    view.set {session}
    view.set training: { created_on: 'test' }
    
    @assert is_active_callback_fired
    @assert can_train_callback_fired
  
  'test nested observe combined with property dependencies': ->
    Country = class extends WingmanObject
      @CODES = 
        DK: 'Denmark'
        UK: 'England'
        SE: 'Sweden'
  
      property_dependencies:
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
  
  'test property dependency for array-like property': ->
    Person = class extends WingmanObject
      property_dependencies:
        fullName: ['names']
      
      fullName: ->
        @get('names').join(' ') if @get('names')
    
    person = new Person
    callback_values = []
    person.observe 'fullName', (value) -> callback_values.push value
    person.set names: []
    person.get('names').push 'Rasmus'
    person.get('names').push 'Nielsen'
    
    @assertEqual '', callback_values[0]
    @assertEqual 'Rasmus', callback_values[1]
    @assertEqual 'Rasmus Nielsen', callback_values[2]
  
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
  
  'test nested observe of array add of yet to be set properties': ->
    context = new WingmanObject
    added = []
    context.observe 'user.notifications', 'add', (new_value) -> added.push(new_value)
    
    user = new WingmanObject
    context.set { user }
    user.set notifications: []
    context.get('user.notifications').push 'Hello'
    
    @assertEqual 'Hello', added[0]

  'test deeply nested observe of array add of yet to be set properties': ->
    context = new WingmanObject
    shared = new WingmanObject
    added = []
    context.observe 'shared.current_club.notifications', 'add', (new_value) -> added.push(new_value)

    context.set { shared }
    
    current_club = new WingmanObject
    current_club.set notifications: []
    shared.set { current_club }
    
    context.get('shared.current_club.notifications').push 'Hello'
    @assertEqual 'Hello', added[0]
    
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
  
  'test export to JSON with object with no set attributes': ->
    obj = new WingmanObject
    json = obj.toJSON()
    @assertEqual 0, Object.keys(json).length
  
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
  
  'test observe once': ->
    context = new WingmanObject
    values_from_callback = []
    context.observeOnce 'name', (value) -> values_from_callback.push(value)
    
    context.set name: 'Rasmus'
    context.set name: 'Lou Bega'
    context.set name: 'Hendrix'
    
    @assertEqual 1, values_from_callback.length
    @assertEqual 'Rasmus', values_from_callback[0]
  
  'test observe once in combination with normal observe': ->
    context = new WingmanObject
    context.observeOnce 'name', -> 'test'
    callback_fired = false
    context.observe 'name', -> callback_fired = true
    context.set name: 'Rasmus'
    @assert callback_fired
