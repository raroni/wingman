Janitor = require 'janitor'
WingmanObject = require '../../../lib/wingman/shared/object'

module.exports = class ObjectTest extends Janitor.TestCase
  @solo: true
  
  'test simplest extend': ->
    object = WingmanObject.extend()
    instance = object.create()
    @assert instance instanceof object
    @assertEqual instance.constructor, object
    @assert instance instanceof WingmanObject
  
  'test simplest create': ->
    instance = WingmanObject.create()
    @assert instance instanceof WingmanObject
  
  'test simple properties': ->
    Viking = WingmanObject.extend
      healthPoints: 100
      takeDamage: (healthPoints) -> @healthPoints -= healthPoints
      lives: 5
    
    thor = Viking.create()
    @assertEqual 100, thor.healthPoints
    thor.takeDamage 25
    @assertEqual 75, thor.healthPoints
    @assertEqual 5, thor.lives
  
  'test create with simple properties': ->
    viking = WingmanObject.create
      healthPoints: 100
      takeDamage: (healthPoints) -> @healthPoints -= healthPoints
      lives: 5
    
    @assertEqual 100, viking.healthPoints
    viking.takeDamage 25
    @assertEqual 75, viking.healthPoints
    @assertEqual 5, viking.lives
  
  'test instantiation with hash': ->
    Person = WingmanObject.extend
      name: null
    
    person = Person.create name: 'Rasmus'
    @assertEqual 'Rasmus', person.name
  
  'test constructor': ->
    Person = WingmanObject.extend
      name: null
      initialize: (@name) ->
    
    dude = Person.create 'The Dude'
    @assertEqual 'The Dude', dude.name
  
  'test basic inheritance': ->
    Person = WingmanObject.extend
      SEXES: ['male', 'female']
      getSex: -> @SEXES[@sexCode]
    
    Woman = Person.extend
      sexCode: 1
    
    woman = Woman.create()
    @assertEqual woman.sex, 'female'
    @assert woman instanceof Woman
    @assert woman instanceof Person
    @assert woman instanceof WingmanObject
  
  'test super': ->
    Dog = WingmanObject.extend
      color: null
      name: null
      giveBirth: ->
        Dog.create color: @color
    
    Snoopy = Dog.extend
      color: 'white'
      
      giveBirth: ->
        dog = @superMethod 'giveBirth'
        dog.name = 'Snoopy Junior'
        dog
    
    snoopy = Snoopy.create()
    puppy = snoopy.giveBirth()
    
    @assert puppy instanceof Dog
    @assertEqual 'white', puppy.color
    @assertEqual 'Snoopy Junior', puppy.name
  
  'test getter': ->
    Person = WingmanObject.extend
      getFullName: -> [@firstName, @lastName].join ' '
    
    person = new Person
    person.firstName = 'Rasmus'
    person.lastName = 'Nielsen'
    @assertEqual 'Rasmus Nielsen', person.fullName
  
  'test observe': ->
    Person = WingmanObject.extend
      name: null
    
    person = new Person
    person.name = 'Roger'
    
    newNameFromCallback = null
    oldNameFromCallback = null
    
    person.observe 'name', (newName, oldName) ->
      newNameFromCallback = newName
      oldNameFromCallback = oldName
    
    person.name = 'Rasmus'
    @assertEqual newNameFromCallback, 'Rasmus'
    @assertEqual oldNameFromCallback, 'Roger'
  
  'test observe of unset properties': ->
    Person = WingmanObject.extend
      name: null
    
    person = new Person
    
    newNameFromCallback = null
    oldNameFromCallback = null
    
    person.observe 'name', (newName, oldName) ->
      newNameFromCallback = newName
      oldNameFromCallback = oldName
    
    person.name = 'Rasmus'
    @assertEqual newNameFromCallback, 'Rasmus'
    @assertEqual oldNameFromCallback, undefined
  
  'test observe of nested unset properties': ->
    Person = WingmanObject.extend
      name: null
      friend: null
    
    rasmus = new Person
    john = new Person
    
    john.name = 'John'
    
    newNameFromCallback = null
    oldNameFromCallback = null
    rasmus.observe 'friend.name', (newName, oldName) ->
      newNameFromCallback = newName
      oldNameFromCallback = oldName
    
    rasmus.friend = john
    
    @assertEqual newNameFromCallback, 'John'
    @assertEqual oldNameFromCallback, undefined
  
  'test two instances of same object': ->
    Car = WingmanObject.extend
      speed: null
    
    car1 = Car.create()
    car1.name = 'car1'
    car1.speed = 100
    
    car2 = Car.create()
    car2.speed = 150
    
    @assertEqual 100, car1.speed
    @assertEqual 150, car2.speed
  
  'test observing on deeply nested properties that are later changed': ->
    View = WingmanObject.extend
      user: null
    
    User = WingmanObject.extend
      car: null
    
    Car = WingmanObject.extend
      speed: null
    
    view = View.create()
    
    callbackValues = []
    
    view.observe 'user.car.speed', (newValue) ->
      callbackValues.push newValue
    
    user = User.create()
    view.user = user
    car1 = Car.create()
    car1.speed = 200000
    car2 = Car.create()
    car2.speed = 10000
    
    user.car = car1
    user.car = car2
    
    @assertEqual 3, callbackValues.length
    @assertEqual undefined, callbackValues[0]
    @assertEqual 200000, callbackValues[1]
    @assertEqual 10000, callbackValues[2]
  
  'test unobserve': ->
    Person = WingmanObject.extend
      name: null
    
    person = new Person
    callbackRan = false
    callback = -> callbackRan = true
    
    person.observe 'name', callback
    person.unobserve 'name', callback
    
    person.name = 'Rasmus'
    
    @assert !callbackRan
  
  'test getting non existing nested property': ->
    person = WingmanObject.create()
    @assertEqual undefined, person.get 'this.does.not.exist'
  
  'test nested get': ->
    carType = WingmanObject.create
      name: 'Toyota'
    
    car = WingmanObject.create
      type: carType
    
    @assertEqual 'Toyota', car.type.name
  
  'test nested observe': ->
    Country = WingmanObject.extend
      name: null
    
    Region = WingmanObject.extend
      country: null
    
    City = WingmanObject.extend
      region: null
    
    denmark = Country.create()
    denmark.name = 'Denmark'
    england = Country.create()
    england.name = 'England'
    sweden = Country.create()
    sweden.name = 'Sweden'
    
    region1 = Region.create()
    region1.country = denmark
    region2 = Region.create()
    region2.country = sweden
    
    city = City.create()
    city.region = region1
  
    newNames = []
    oldNames = []
    city.observe 'region.country.name', (newName, oldName) ->
      newNames.push newName
      oldNames.push oldName
  
    denmark.name = 'Denmark test'
    region1.country = england
    denmark.name = 'Denmark test2'
    city.region = region2
  
    @assertEqual 3, newNames.length
    @assertEqual 'Denmark test', newNames[0]
    @assertEqual 'England', newNames[1]
    @assertEqual 'Sweden', newNames[2]
  
    @assertEqual 3, oldNames.length
    @assertEqual 'Denmark', oldNames[0]
    @assertEqual 'Denmark test', oldNames[1]
    @assertEqual 'England', oldNames[2]
  
  'test setting several properties at once': ->
    person = WingmanObject.create
      firstName: null
      lastName: null
    
    person.set firstName: 'Rasmus', lastName: 'Nielsen'
    
    @assertEqual 'Rasmus', person.firstName
    @assertEqual 'Nielsen', person.lastName
  
  'test observe while setting several properties at once': ->
    person = WingmanObject.create
      firstName: null
      lastName: null
    
    callbackValue = null
    person.observe 'firstName', (value) -> callbackValue = value
    person.set firstName: 'Rasmus', lastName: 'Nielsen'
    
    @assertEqual 'Rasmus', callbackValue
  
  'test observe array property add': ->
    app = WingmanObject.extend
      users: null
    
    instance = app.create
      users: []
    
    added = []
    instance.users.bind 'add', (newValue) -> added.push(newValue)
    instance.users.push 'Rasmus'
    instance.users.push 'John'
    instance.users = []
    instance.users.push 'Jack'
    
    @assertEqual 2, added.length
    @assertEqual 'Rasmus', added[0]
    @assertEqual 'John', added[1]
    @assertEqual 1, instance.users.length
  
  'test observe nested array property': ->
    country = WingmanObject.create cities: null
    country.cities = ['London', 'Manchester']
    user = WingmanObject.create { country }
    
    result = undefined
    user.observe 'country.cities', 'add', (newValue) -> result = newValue
    country.cities.push 'Liverpool'
    
    @assertEqual 'Liverpool', result
  
  'test nested observe of array add of yet to be set properties': ->
    added = []
    
    context = WingmanObject.create user: null
    context.observe 'user.notifications', 'add', (newValue) -> added.push(newValue)
    
    user = WingmanObject.create notifications: null
    user.notifications = []
    
    context.user = user
    context.user.notifications.push 'Hello'
    
    @assertEqual 'Hello', added[0]
  
  'test nested observe of enumerable that is being reset': ->
    added = []
    
    context = WingmanObject.create user: null
    context.observe 'user.notifications', 'add', (newValue) -> added.push(newValue)
    
    user = WingmanObject.create notifications: null
    user.notifications = []
    
    context.user = user
    
    user.notifications = []
    context.user.notifications.push 'Hello'
    
    @assertEqual 'Hello', added[0]
  
  'test deeply nested observe of array add of yet to be set properties': ->
    context = WingmanObject.create shared: null
    shared = WingmanObject.create currentUser: null
    
    added = []
    context.observe 'shared.currentUser.notifications', 'add', (newValue) -> added.push(newValue)
    
    context.shared = shared
    
    currentUser = WingmanObject.create notifications: null
    currentUser.notifications = []
    shared.currentUser = currentUser
    
    context.shared.currentUser.notifications.push 'Hello'
    @assertEqual 'Hello', added[0]
    
  'test observe array property remove': ->
    country = WingmanObject.create cities: null
    country.cities = ['London', 'Manchester']
    removedValueFromCallback = ''
    country.observe 'cities', 'remove', (removedValue) -> removedValueFromCallback = removedValue
    country.cities.remove 'London'
    
    @assertEqual 'London', removedValueFromCallback
    @assertEqual 'Manchester', country.cities[0]
    @assertEqual 1, country.cities.length  
    
  'test property dependencies': ->
    Person = WingmanObject.extend
      firstName: null
      lastName: null
      propertyDependencies:
        fullName: ['firstName', 'lastName']
      
      getFullName: -> [@firstName, @lastName].join ' '
    
    person = Person.create()
    callbackValues = []
    person.observe 'fullName', (newValue) -> callbackValues.push newValue
    person.set firstName: 'Rasmus', lastName: 'Nielsen'
    
    @assertEqual 'Rasmus Nielsen', callbackValues[callbackValues.length-1]
    
    # TODO:
    #@assertEqual 1, callbackValues.length
    #@assertEqual 'Rasmus Nielsen', callbackValues[0]
  
  'test property dependencies with single depending property': ->
    Country = WingmanObject.extend
      countryCode: null
      
      NAMES:
        dk: 'Denmark'
        se: 'Sweden'
      propertyDependencies:
        countryName: 'countryCode'
      
      getCountryName: -> @NAMES[@countryCode]
    
    country = Country.create()
    result = undefined
    country.observe 'countryName', (newValue) -> result = newValue
    country.countryCode = 'dk'
    
    @assertEqual 'Denmark', result
  
  'test observation of computed property that is reevaluated but not changed': ->
    Person = WingmanObject.extend
      car: null
      propertyDependencies:
        isHappy: 'car'
    
      getIsHappy: -> @car == 'Batmobile'
    
    person = Person.create()
    callbackValues = []
    person.observe 'isHappy', (value) -> callbackValues.push value
    person.car = 'Lada'
    person.car = 'Toyota'
    person.car = 'Batmobile'
    person.car = 'Volkswagen'
    
    @assertEqual 3, callbackValues.length
    @assertEqual false, callbackValues[0]
    @assertEqual true, callbackValues[1]
    @assertEqual false, callbackValues[2]
  
  'test observe once': ->
    context = WingmanObject.create name: null
    valuesFromCallback = []
    context.observeOnce 'name', (value) -> valuesFromCallback.push(value)
    
    context.name = 'Rasmus'
    context.name = 'Lou Bega'
    context.name = 'Hendrix'
    
    @assertEqual 1, valuesFromCallback.length
    @assertEqual 'Rasmus', valuesFromCallback[0]
  
  'test observe once in combination with normal observe': ->
    context = WingmanObject.create name: null
    context.observeOnce 'name', -> 'test'
    callbackFired = false
    context.observe 'name', -> callbackFired = true
    context.name = 'Rasmus'
    @assert callbackFired
  
  'test nested property dependencies': ->
    session = WingmanObject.create
      cake: null
    
    View = WingmanObject.extend
      session: null
      propertyDependencies:
        isHappy: 'session.cake'
      
      getIsHappy: -> !!@get('session.cake')
    
    view = View.create()
    callbackValue = undefined
    view.observe 'isHappy', (value) -> callbackValue = value
    view.session = session
    session.cake = 'strawberry'
    @assert callbackValue
  
  'test nested observe combined with property dependencies': ->
    Country = WingmanObject.extend
      CODES:
        DK: 'Denmark'
        UK: 'England'
        SE: 'Sweden'
      
      propertyDependencies:
        name: ['code']
      
      code: null
      
      getName: ->
        @CODES[@get('code')]
    
    Region = WingmanObject.extend
      country: null
    
    City = WingmanObject.extend
      region: null
    
    denmark = Country.create code: 'DK'
    england = Country.create code: 'UK'
    sweden = Country.create code: 'SE'
    
    region1 = Region.create country: denmark
    region2 = WingmanObject.create country: sweden
    
    city = City.create region: region1
    
    names = []
    city.observe 'region.country.name', (newName) -> names.push(newName)
    denmark.code = 'SE'
    region1.country = england
    denmark.code = 'UK'
    city.region = region2
  
    @assertEqual 3, names.length
    @assertEqual 'Sweden', names[0]
    @assertEqual 'England', names[1]
    @assertEqual 'Sweden', names[2]
  
  'test property depending on enumerable': ->
    Person = WingmanObject.extend
      propertyDependencies:
        fullName: 'names'
      
      names: null
      
      getFullName: ->
        @names.join ' ' if @names
    
    person = Person.create names: []
    
    callbackValues = []
    person.observe 'fullName', (value) -> callbackValues.push value
    person.names.push 'Rasmus'
    person.names.push 'Nielsen'
    
    @assertEqual 'Rasmus', callbackValues[0]
    @assertEqual 'Rasmus Nielsen', callbackValues[1]
  
  'test property dependency inheritance': ->
    Parent = WingmanObject.extend
      currentUser: null
      
      propertyDependencies:
        loggedIn: 'currentUser'
      
      getLoggedIn: ->
        !!@get('currentUser')
    
    Child = Parent.extend
      propertyDependencies:
        something: 'loggedIn'
      
      getSomething: ->
    
    child = Child.create()
    callbackFired = false
    child.observe 'something', -> callbackFired = true
    child.currentUser = 'yogi'
    @assert callbackFired
  
  'test childrens property dependencies doesnt affect parents': ->
    Parent = WingmanObject.extend
      propertyDependencies:
        loggedIn: 'currentUser'
      
      currentUser: null
      
      loggedIn: ->
        !!@currentUser
    
    Child = Parent.extend
      propertyDependencies:
        something: 'loggedIn'
      
      something: ->
    
    parent = Parent.create()
    parentCallbackFired = false
    parent.observe 'something', -> parentCallbackFired = true
    parent.currentUser = 'bobo'
    @assert !parentCallbackFired
  
  'test export to JSON': ->
    Country = WingmanObject.extend
      code: null
      region: null
      name: -> 'method properties should not be a part of toJSON'
      otherProperty: => 'not even if you bind them like this'
        
    country = Country.create code: 'dk', region: 'eu'
    
    json = country.toJSON()
    @assertEqual 'dk', json.code
    @assertEqual 'eu', json.region
    @assertEqual 2, Object.keys(json).length
  
  'test export with no properties': ->
    Country = WingmanObject.extend()
    country = Country.create()
    json = country.toJSON()
    @assertEqual 0, Object.keys(json).length
  
  'test export to JSON with only options': ->
    Country = WingmanObject.extend
      code: null
      region: null
    
    country = Country.create code: 'dk', region: 'eu', population: 5000
    onlyCode = country.toJSON only: 'code'
    @assertEqual 'dk', onlyCode.code
    @assertEqual 1, Object.keys(onlyCode).length
    
    onlyCodeAndRegion = country.toJSON only: ['code', 'region']
    
    @assertEqual 'dk', onlyCodeAndRegion.code
    @assertEqual 'eu', onlyCodeAndRegion.region
    @assertEqual 2, Object.keys(onlyCodeAndRegion).length
  
  'test intelligent properties and json export': ->
    thingamabob = WingmanObject.create()
    
    Context = WingmanObject.extend name: null, age: null, engine: null
    context = Context.create
      name: 'Guybrush'
      age: 25
      engine: thingamabob
    
    json = context.toJSON()
    
    @assertEqual 2, Object.keys(json).length
    @assertEqual 'Guybrush', json.name
    @assertEqual 25, json.age
