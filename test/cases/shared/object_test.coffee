Janitor = require 'janitor'
WingmanObject = require '../../../lib/wingman/shared/object'

module.exports = class ObjectTest extends Janitor.TestCase
  'test simplest extend': ->
    Constructor = WingmanObject.extend()
    instance = new Constructor
    @assert instance instanceof Constructor
    @assertEqual instance.constructor, Constructor
    @assert instance instanceof WingmanObject
  
  'test simplest create': ->
    instance = new WingmanObject
    @assert instance instanceof WingmanObject
    @assertEqual instance.constructor, WingmanObject
    @assertEqual WingmanObject.prototype, Object.getPrototypeOf(instance)
  
  'test reusing defined properties': ->
    Person = WingmanObject.extend
      name: null
    
    person = new Person
    person.name = 'Rasmus'
    @assert Person.prototype.hasOwnProperty('name')
    @refute person.hasOwnProperty('name')
  
  'test simple properties': ->
    Viking = WingmanObject.extend
      healthPoints: 100
      takeDamage: (healthPoints) -> @healthPoints -= healthPoints
      lives: 5
    
    thor = new Viking
    @assertEqual 100, thor.healthPoints
    thor.takeDamage 25
    @assertEqual 75, thor.healthPoints
    @assertEqual 5, thor.lives
  
  'test property enumerating': ->
    Constructor = WingmanObject.extend name: null, age: null
    obj = new Constructor
    obj.name = 'Rasmus'
    obj.age = 26
    result = {}
    result[key] = value for key, value of obj
    
    @assertEqual 'Rasmus', result.name
    @assertEqual 26, result.age
  
  'test create with simple properties': ->
    Viking = WingmanObject.extend
      healthPoints: 100
      takeDamage: (healthPoints) -> @healthPoints -= healthPoints
      lives: 5
    
    viking = new Viking
    
    @assertEqual 100, viking.healthPoints
    viking.takeDamage 25
    @assertEqual 75, viking.healthPoints
    @assertEqual 5, viking.lives
  
  'test initialize': ->
    Person = WingmanObject.extend
      initialize: (@name, @age) ->
    
    dude = new Person 'The Dude', 25
    @assertEqual 'The Dude', dude.name
    @assertEqual 25, dude.age
  
  'test basic inheritance': ->
    Person = WingmanObject.extend
      SEXES: ['male', 'female']
      getSex: -> @SEXES[@sexCode]
    
    Woman = Person.extend
      sexCode: 1
    
    woman = new Woman
    @assertEqual woman.sex, 'female'
    @assert woman instanceof Woman
    @assert woman instanceof Person
    @assert woman instanceof WingmanObject
  
  'test reusing defined properties across inheritance': ->
    Dog = WingmanObject.extend
      name: null
    
    Snoopy = Dog.extend
      name: 'Snoopy'
    
    snoopy = new Snoopy
    
    @assertEqual 'Snoopy', snoopy.name
    @refute Snoopy.prototype.hasOwnProperty('name')
    @refute snoopy.hasOwnProperty('name')
    @assert Dog.prototype.hasOwnProperty('name')
  
  'test inheriting class properties': ->
    Prototype = {}
    ClassProperties = doSomething: 'test'
    Animal = WingmanObject.extend Prototype, ClassProperties
    Dog = Animal.extend()
    
    @assertEqual 'test', Dog.doSomething
  
  'test super': ->
    Dog = WingmanObject.extend
      initialize: (hash) ->
        @[key] = value for key, value of hash
      
      giveBirth: (name) ->
        new Dog { color: @color, name }
    
    Snoopy = Dog.extend
      color: 'white'
      
      giveBirth: ->
        @_super 'Snoopy Junior'
    
    snoopy = new Snoopy
    puppy = snoopy.giveBirth()
    
    @assert puppy instanceof Dog
    @assertEqual 'white', puppy.color
    @assertEqual 'Snoopy Junior', puppy.name
  
  'test preserving correct super across several methods': ->
    Animal = WingmanObject.extend
      identify: -> "I am a #{@name}"
    
    Dog = Animal.extend
      name: 'dog'
      
      identify: ->
        @someOtherMethod()
        @_super()
      
      someOtherMethod: ->
        'just testing'
    
    dog = new Dog
    @assertEqual 'I am a dog', dog.identify()
  
  'test include': ->
    Loader =
      getProgress: -> "#{@percentage}%"
      percentage: 85
    
    App = WingmanObject.extend()
    App.include Loader
    
    @assertEqual '85%', App.progress
  
  'test including two modules': ->
    Loader = getProgress: -> '85%'
    Controller = control: -> 'I rule!'
    
    App = WingmanObject.extend()
    App.include Loader, Controller
    
    @assertEqual '85%', App.progress
    @assertEqual 'I rule!', App.control()
  
  'test prototype include': ->
    Walker =
      position: 0
      walk: -> @position += 2
      getLegs: -> '||'
    
    Person = WingmanObject.extend()
    Person.prototype.include Walker
    
    person = new Person
    person.walk()
    
    @assertEqual 2, person.position
    @assertEqual '||', person.legs
  
  'test prototype including two modules': ->
    Walker = { walk: -> true }
    Seer = { see: -> true }
    
    Person = WingmanObject.extend()
    Person.prototype.include Walker, Seer
    
    person = new Person
    @assert person.walk()
    @assert person.see()
  
  'test getter': ->
    Person = WingmanObject.extend
      getFullName: -> [@firstName, @lastName].join ' '
    
    person = new Person
    person.firstName = 'Rasmus'
    person.lastName = 'Nielsen'
    @assertEqual 'Rasmus Nielsen', person.fullName
  
  'test getters and enumeration': ->
    Constructor = WingmanObject.extend
      getName: -> 'Rasmus'
      getAge: -> 26
    
    instance = new Constructor
    
    result = {}
    result[key] = value for key, value of instance
    
    @assertEqual 'Rasmus', result.name
    @assertEqual 26, result.age
  
  'test getter with create': ->
    Person = WingmanObject.extend
      firstName: 'Rasmus'
      lastName: 'Nielsen'
      getFullName: -> [@firstName, @lastName].join ' '
    
    person = new Person
    
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
    Person = WingmanObject.extend name: null
    person = new Person
    
    newNameFromCallback = null
    oldNameFromCallback = null
    
    person.observe 'name', (newName, oldName) ->
      newNameFromCallback = newName
      oldNameFromCallback = oldName
    
    person.name = 'Rasmus'
    @assertEqual newNameFromCallback, 'Rasmus'
    @assertEqual oldNameFromCallback, null
  
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
    
    car1 = new Car
    car1.name = 'car1'
    car1.speed = 100
    
    car2 = new Car
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
    
    view = new View
    
    callbackValues = []
    
    view.observe 'user.car.speed', (newValue) ->
      callbackValues.push newValue
    
    user = new User
    view.user = user
    car1 = new Car
    car1.speed = 200000
    car2 = new Car
    car2.speed = 10000
    
    user.car = car1
    user.car = car2
    
    @assertEqual 3, callbackValues.length
    @assertEqual undefined, callbackValues[0]
    @assertEqual 200000, callbackValues[1]
    @assertEqual 10000, callbackValues[2]
  
  'test reseting property that is a part of a nested observe': ->
    User = WingmanObject.extend name: null
    user = new User
    user.name = 'Ras'
    
    View = WingmanObject.extend user: null
    view = new View
    view.user = user
    
    view.observe 'user.name', ->
    @refuteThrows -> view.user = null
  
  'test unobserve': ->
    Person = WingmanObject.extend name: null
    person = new Person
    
    callbackValues = []
    callback1 = -> callbackValues.push 'a'
    callback2 = -> callbackValues.push 'b'
    
    person.observe 'name', callback1
    person.observe 'name', callback2
    person.unobserve 'name', callback1
    
    person.name = 'Rasmus'
    
    @assertEqual 1, callbackValues.length
    @assertEqual 'b', callbackValues[0]
  
  'test getting non existing nested property': ->
    person = new WingmanObject
    @assertEqual undefined, person.get 'this.does.not.exist'
  
  'test nested get': ->
    CarType = WingmanObject.extend initialize: (@name) ->
    carType = new CarType 'Toyota'
    
    Car = WingmanObject.extend initialize: (@type) ->
    car = new Car carType
    
    @assertEqual 'Toyota', car.type.name
  
  'test nested observe': ->
    Country = WingmanObject.extend name: null, initialize: (@name) ->
    Region = WingmanObject.extend country: null, initialize: (@country) ->
    City = WingmanObject.extend region: null, initialize: (@region) ->
    
    denmark = new Country 'Denmark'
    england = new Country 'England'
    sweden = new Country 'Sweden'
    
    region1 = new Region denmark
    region2 = new Region sweden
    
    city = new City region1
    
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
    person = new WingmanObject
      firstName: null
      lastName: null
    
    person.set firstName: 'Rasmus', lastName: 'Nielsen'
    
    @assertEqual 'Rasmus', person.firstName
    @assertEqual 'Nielsen', person.lastName
  
  'test observe while setting several properties at once': ->
    Person = WingmanObject.extend
      firstName: null
      lastName: null
    
    person = new Person
    
    callbackValue = null
    person.observe 'firstName', (value) -> callbackValue = value
    person.set firstName: 'Rasmus', lastName: 'Nielsen'
    
    @assertEqual 'Rasmus', callbackValue
  
  'test observe array property add': ->
    App = WingmanObject.extend users: null, initialize: -> @users = []
    app = new App
    
    added = []
    app.users.bind 'add', (newValue) -> added.push(newValue)
    app.users.push 'Rasmus'
    app.users.push 'John'
    app.users = []
    app.users.push 'Jack'
    
    @assertEqual 2, added.length
    @assertEqual 'Rasmus', added[0]
    @assertEqual 'John', added[1]
    @assertEqual 1, app.users.length
  
  'test observe nested array property': ->
    Country = WingmanObject.extend cities: null
    country = new Country
    country.cities = ['London', 'Manchester']
    User = WingmanObject.extend country: null
    user = new User
    user.country = country
    
    result = undefined
    user.observe 'country.cities', 'add', (newValue) -> result = newValue
    country.cities.push 'Liverpool'
    
    @assertEqual 'Liverpool', result
  
  'test nested observe of array add of yet to be set properties': ->
    added = []
    
    Context = WingmanObject.extend user: null
    context = new Context
    context.observe 'user.notifications', 'add', (newValue) -> added.push(newValue)
    
    User = WingmanObject.extend notifications: null
    user = new User
    user.notifications = []
    
    context.user = user
    context.user.notifications.push 'Hello'
    
    @assertEqual 'Hello', added[0]
  
  'test nested observe of enumerable that is being reset': ->
    added = []
    
    Context = WingmanObject.extend user: null
    context = new Context
    context.observe 'user.notifications', 'add', (newValue) -> added.push(newValue)
    
    User = WingmanObject.extend notifications: null
    user = new User
    user.notifications = []
    
    context.user = user
    
    user.notifications = []
    context.user.notifications.push 'Hello'
    
    @assertEqual 'Hello', added[0]
  
  'test deeply nested observe of array add of yet to be set properties': ->
    Context = WingmanObject.extend shared: null
    context = new Context
    Shared = WingmanObject.extend currentUser: null
    shared = new Shared
    
    added = []
    context.observe 'shared.currentUser.notifications', 'add', (newValue) -> added.push(newValue)
    
    context.shared = shared
    
    User = WingmanObject.extend notifications: null
    currentUser = new User
    currentUser.notifications = []
    shared.currentUser = currentUser
    
    context.shared.currentUser.notifications.push 'Hello'
    @assertEqual 'Hello', added[0]
  
  'test observe array property remove': ->
    Country = WingmanObject.extend cities: null
    country = new Country
    country.cities = ['London', 'Manchester']
    removedValueFromCallback = ''
    country.observe 'cities', 'remove', (removedValue) -> removedValueFromCallback = removedValue
    country.cities.remove 'London'
    
    @assertEqual 'London', removedValueFromCallback
    @assertEqual 'Manchester', country.cities[0]
    @assertEqual 1, country.cities.length  
  
  'test observe once': ->
    Context = WingmanObject.extend name: null
    context = new Context
    valuesFromCallback = []
    context.observeOnce 'name', (value) -> valuesFromCallback.push(value)
    
    context.name = 'Rasmus'
    context.name = 'Lou Bega'
    context.name = 'Hendrix'
    
    @assertEqual 1, valuesFromCallback.length
    @assertEqual 'Rasmus', valuesFromCallback[0]
  
  'test observe once in combination with normal observe': ->
    Context = WingmanObject.extend name: null
    context = new Context
    context.observeOnce 'name', -> 'test'
    callbackFired = false
    context.observe 'name', -> callbackFired = true
    context.name = 'Rasmus'
    @assert callbackFired
  
  'test property dependencies': ->
    Person = WingmanObject.extend
      firstName: null
      lastName: null
      
      getFullName: -> [@firstName, @lastName].join ' '
    
    Person.addPropertyDependencies
      fullName: ['firstName', 'lastName']
    
    person = new Person
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
      
      getCountryName: -> @NAMES[@countryCode]
    
    Country.addPropertyDependencies countryName: 'countryCode'
    
    country = new Country
    result = undefined
    country.observe 'countryName', (newValue) -> result = newValue
    country.countryCode = 'dk'
    
    @assertEqual 'Denmark', result
  
  'test observation of computed property that is reevaluated but not changed': ->
    Person = WingmanObject.extend
      car: null
    
      getIsHappy: -> @car == 'Batmobile'
    
    Person.addPropertyDependencies isHappy: 'car'
    
    person = new Person
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
  
  'test nested property dependencies': ->
    Session = WingmanObject.extend cake: null
    session = new Session
    
    View = WingmanObject.extend
      session: null
      
      getIsHappy: -> !!@get('session.cake')
    
    View.addPropertyDependencies isHappy: 'session.cake'
    
    view = new View
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
      
      code: null
      
      initialize: (@code) ->
        @_super()
      
      getName: ->
        @CODES[@get('code')]
    
    Country.addPropertyDependencies name: 'code'
    
    Region = WingmanObject.extend
      country: null
      initialize: (@country) ->
    
    City = WingmanObject.extend
      region: null
      initialize: (@region) ->
    
    denmark = new Country 'DK'
    england = new Country 'UK'
    sweden = new Country 'SE'
    
    region1 = new Region denmark
    region2 = new Region sweden
    
    city = new City region1
    
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
      names: null
      
      initialize: ->
        @names = []
        @_super()
      
      getFullName: ->
        @names.join ' ' if @names
    
    Person.addPropertyDependencies fullName: 'names'
    
    person = new Person
    
    callbackValues = []
    person.observe 'fullName', (value) ->
      callbackValues.push value
    
    person.names.push 'Rasmus'
    person.names.push 'Nielsen'
    
    person.names.remove 'Rasmus'
    
    person.names = ['Johnny']
    
    @assertEqual 'Rasmus', callbackValues[0]
    @assertEqual 'Rasmus Nielsen', callbackValues[1]
    @assertEqual 'Nielsen', callbackValues[2]
    @assertEqual 'Johnny', callbackValues[3]
  
  'test property dependency inheritance': ->
    Parent = WingmanObject.extend
      currentUser: null
      
      getLoggedIn: ->
        !!@get('currentUser')
    
    Parent.addPropertyDependencies loggedIn: 'currentUser'
    
    Child = Parent.extend getSomething: ->
    Child.addPropertyDependencies something: 'loggedIn'
    
    child = new Child
    
    callbackFired = false
    child.observe 'something', -> callbackFired = true
    child.currentUser = 'yogi'
    @assert callbackFired
  
  'test property dependency inheritance when child has no dependencies': ->
    MyApp = WingmanObject.extend
      userId: null
      getLoggedIn: -> !!@userId
    
    MyApp.addPropertyDependencies loggedIn: 'userId'
    
    ChildApp = MyApp.extend()
    childApp = new ChildApp
    callbackFired = false
    childApp.observe 'loggedIn', -> callbackFired = true
    childApp.userId = 1
    @assert callbackFired
  
  'test childrens property dependencies doesnt affect parents': ->
    Parent = WingmanObject.extend
      currentUser: null
      
      loggedIn: ->
        !!@currentUser
    
    Parent.addPropertyDependencies loggedIn: 'currentUser'
    
    Child = Parent.extend something: ->
    Child.addPropertyDependencies something: 'loggedIn'
    
    
    parent = new Parent
    parentCallbackFired = false
    parent.observe 'something', -> parentCallbackFired = true
    parent.currentUser = 'bobo'
    @assert !parentCallbackFired
  
  'test export to JSON': ->
    Country = WingmanObject.extend
      code: null
      region: null
      initialize: (@code, @region) ->
      name: -> 'method properties should not be a part of toJSON'
      otherProperty: => 'not even if you bind them like this'
        
    country = new Country 'dk', 'eu'
    
    json = country.toJSON()
    @assertEqual 'dk', json.code
    @assertEqual 'eu', json.region
    @assertEqual 2, Object.keys(json).length
  
  'test export with no properties': ->
    Country = WingmanObject.extend()
    country = new Country
    json = country.toJSON()
    @assertEqual 0, Object.keys(json).length
  
  'test export to JSON with only options': ->
    Country = WingmanObject.extend
      code: null
      region: null
      initialize: (hash) ->
        @[key] = value for key, value of hash
    
    country = new Country code: 'dk', region: 'eu', population: 5000
    onlyCode = country.toJSON only: 'code'
    @assertEqual 'dk', onlyCode.code
    @assertEqual 1, Object.keys(onlyCode).length
    
    onlyCodeAndRegion = country.toJSON only: ['code', 'region']
    
    @assertEqual 'dk', onlyCodeAndRegion.code
    @assertEqual 'eu', onlyCodeAndRegion.region
    @assertEqual 2, Object.keys(onlyCodeAndRegion).length
  
  'test intelligent properties and json export': ->
    thingamabob = new WingmanObject
    
    Context = WingmanObject.extend
      name: null
      age: null
      engine: null
      
      initialize: (hash) ->
        @[key] = value for key, value of hash
    
    context = new Context
      name: 'Guybrush'
      age: 25
      engine: thingamabob
    
    json = context.toJSON()
    
    @assertEqual 2, Object.keys(json).length
    @assertEqual 'Guybrush', json.name
    @assertEqual 25, json.age
  
  'test sub context': ->
    outer = new WingmanObject
    outer.name = 'Outer'
    inner = outer.createSubContext()
    
    @assertEqual 'Outer', inner.name
    
    inner.name = 'Inner'
    @assertEqual 'Inner', inner.name
    @assertEqual 'Outer', outer.name
  
  'test overwriting a getter with normal propery': ->
    Parent = WingmanObject.extend
      getName: -> 'I am a method!'
    
    Child = Parent.extend
      name: 'A string will do'
    
    child = new Child
    @assertEqual 'A string will do', child.name
    
    parent = new Parent
    @assertEqual 'I am a method!', parent.name
  
  'test overriding setProperty': ->
    Model = WingmanObject.extend
      name: null
      
      setProperty: (key, value) ->
        @_super key, "#{value} set by Model"
    
    model = new Model
    model.name = 'Yoshi'
    @assertEqual 'Yoshi set by Model', model.name
  
  'test isInstance': ->
    Dog = WingmanObject.extend()
    dog = new Dog
    Puppy = Dog.extend()
    puppy = new Puppy
    
    @assert dog.isInstance()
    @assert puppy.isInstance()
    @refute Dog.prototype.isInstance()
    @refute Puppy.prototype.isInstance()
  
  'test isIstance used when extending': ->
    callbackValues = []
    Model = WingmanObject.extend
      setProperty: (key, value) ->
        callbackValues.push @isInstance()
        @_super key, value
    
    User = Model.extend name: 'Rasmus'
    user = new User
    user.name = 'John'
    
    @assertEqual 2, callbackValues.length
    @refute callbackValues[0]
    @assert callbackValues[1]
