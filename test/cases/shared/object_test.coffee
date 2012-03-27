Janitor = require 'janitor'
WingmanObject = require '../../../lib/wingman/shared/object'

module.exports = class ObjectTest extends Janitor.TestCase
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
  
    newNameFromCallback = ''
    oldNameFromCallback = ''
    person.observe 'name', (newName, oldName) ->
      newNameFromCallback = newName
      oldNameFromCallback = oldName
    person.set name: 'Rasmus'
    @assertEqual newNameFromCallback, 'Rasmus'
    @assertEqual oldNameFromCallback, 'Roger'
  
  'test observe of unset properties': ->
    Person = class extends WingmanObject
    person = new Person
  
    newNameFromCallback = ''
    oldNameFromCallback = ''
    person.observe 'name', (newName, oldName) ->
      newNameFromCallback = newName
      oldNameFromCallback = oldName
    person.set name: 'Rasmus'
    @assertEqual newNameFromCallback, 'Rasmus'
    @assertEqual oldNameFromCallback, undefined
  
  'test observe of nested unset properties': ->
    Person = class extends WingmanObject
    rasmus = new Person
    john = new Person
    john.set name: 'John'
  
    newNameFromCallback = ''
    oldNameFromCallback = ''
    
    rasmus.observe 'friend.name', (newName, oldName) ->
      newNameFromCallback = newName
      oldNameFromCallback = oldName
    rasmus.set friend: john
    
    @assertEqual newNameFromCallback, 'John'
    @assertEqual oldNameFromCallback, undefined
  
  'test observing on deeply nested properties that are later changed': ->
    view = new WingmanObject
    latestvalueFromCallback = undefined
    view.observe 'user.car.kilometersDriven', (newValue) -> latestvalueFromCallback = newValue
  
    user = new WingmanObject
    view.set { user }
    car1 = new WingmanObject
    car1.set kilometersDriven: 200000
    car2 = new WingmanObject
    car2.set kilometersDriven: 10000
    
    user.set car: car1
    user.set car: car2
    
    @assertEqual 10000, latestvalueFromCallback
  
  'test unobserve': ->
    Person = class extends WingmanObject
    person = new Person
    callbackRun = false
    callback = ->
      callbackRun = true
    person.observe 'name', callback
    person.unobserve 'name', callback
    person.set name: 'Rasmus'
    @assert !callbackRun
  
  'test getting non existing nested property': ->
    Person = class extends WingmanObject
    person = new Person
    @assertEqual undefined, person.get 'this.does.not.exist'
  
  'test nested get': ->
    Car = class extends WingmanObject
    CarType = class extends WingmanObject
    
    slowCar = new CarType
    slowCar.set name: 'Toyota'
    car = new Car()
    car.set type: slowCar
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
  
    newNames = []
    oldNames = []
    city.observe 'region.country.name', (newName, oldName) ->
      newNames.push newName
      oldNames.push oldName
  
    denmark.set name: 'Denmark test'
    region1.set country: england
    denmark.set name: 'Denmark test2'
    city.set region: region2
  
    @assertEqual 3, newNames.length
    @assertEqual 'Denmark test', newNames[0]
    @assertEqual 'England', newNames[1]
    @assertEqual 'Sweden', newNames[2]
  
    @assertEqual 3, oldNames.length
    @assertEqual 'Denmark', oldNames[0]
    @assertEqual 'Denmark test', oldNames[1]
    @assertEqual 'England', oldNames[2]
  
  'test property dependencies': ->
    Person = class extends WingmanObject
      @propertyDependencies
        fullName: ['firstName', 'lastName']
      
      fullName: -> "#{@get('firstName')} #{@get('lastName')}"
    
    person = new Person
    result = ''
    person.observe 'fullName', (newValue) -> result = newValue
    person.set firstName: 'Rasmus', lastName: 'Nielsen'
    
    @assertEqual 'Rasmus Nielsen', result
  
  'test observation of computed property that is reevaluated but not changed': ->
    Person = class extends WingmanObject
      @propertyDependencies
        isHappy: 'car'
    
      isHappy: -> @get('car') == 'Batmobile'
    
    person = new Person
    callbackValues = []
    person.observe 'isHappy', (value) -> callbackValues.push value
    person.set car: 'Lada'
    person.set car: 'Toyota'
    person.set car: 'Batmobile'
    person.set car: 'Volkswagen'
    
    @assertEqual 3, callbackValues.length
    @assertEqual false, callbackValues[0]
    @assertEqual true, callbackValues[1]
    @assertEqual false, callbackValues[2]
  
  'test property dependencies with single depending property': ->
    Country = class extends WingmanObject
      @NAMES: { dk: 'Denmark', se: 'Sweden' }
      
      @propertyDependencies
        countryName: 'countryCode'
      
      countryName: -> @constructor.NAMES[@get('countryCode')]
    
    country = new Country
    result = undefined
    country.observe 'countryName', (newValue) -> result = newValue
    country.set countryCode: 'dk'
  
    @assertEqual 'Denmark', result
  
  'test nested property dependencies': ->
    session = new WingmanObject
    View = class extends WingmanObject
      @propertyDependencies
        isHappy: 'session.cake'
      
      isHappy: ->
        !!@get('session.cake')
    
    view = new View
    callbackValue = undefined
    view.observe 'isHappy', (value) -> callbackValue = value
    view.set { session }
    session.set cake: 'strawberry'
    @assert callbackValue
  
  'test several nested property dependencies': ->
    session = new WingmanObject
    session.set userId: 1
    
    View = class extends WingmanObject
      @propertyDependencies
        isActive: 'session.userId'
        canTrain: 'training.createdOn'
      
      canTrain: ->
        @get('training.createdOn') != '2012-01-26'
      
      isActive: ->
        !!@get('session.userId')
    
    view = new View
    isActiveCallbackFired = false
    canTrainCallbackFired = false
    view.observe 'isActive', -> isActiveCallbackFired = true
    view.observe 'canTrain', -> canTrainCallbackFired = true
    view.set { session }
    view.set training: { createdOn: 'test' }
    
    @assert isActiveCallbackFired
    @assert canTrainCallbackFired
  
  'test nested observe combined with property dependencies': ->
    Country = class extends WingmanObject
      @CODES = 
        DK: 'Denmark'
        UK: 'England'
        SE: 'Sweden'
  
      @propertyDependencies
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
    city.observe 'region.country.name', (newName) -> names.push(newName)
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
      @propertyDependencies
        fullName: 'names'
      
      fullName: ->
        @get('names').join(' ') if @get('names')
    
    person = new Person
    callbackValues = []
    person.observe 'fullName', (value) -> callbackValues.push value
    person.set names: []
    person.get('names').push 'Rasmus'
    person.get('names').push 'Nielsen'
    
    @assertEqual '', callbackValues[0]
    @assertEqual 'Rasmus', callbackValues[1]
    @assertEqual 'Rasmus Nielsen', callbackValues[2]
  
  'test property dependency inheritance': ->
    class Parent extends WingmanObject
      @propertyDependencies
        loggedIn: 'currentUser'
      
      loggedIn: ->
        !!@get('currentUser')
    
    class Child extends Parent
      @propertyDependencies
        something: 'loggedIn'
      
      something: ->
    
    child = new Child
    callbackFired = false
    child.observe 'something', -> callbackFired = true
    child.set currentUser: 'yogi'
    @assert callbackFired
  
  'test childrens property dependencies doesnt affect parents': ->
    class Parent extends WingmanObject
      @propertyDependencies
        loggedIn: 'currentUser'
      
      loggedIn: ->
        !!@get('currentUser')
    
    class Child extends Parent
      @propertyDependencies
        something: 'loggedIn'
      
      something: ->
    
    parent = new Parent
    parentCallbackFired = false
    parent.observe 'something', -> parentCallbackFired = true
    parent.set currentUser: 'bobo'
    @assert !parentCallbackFired
  
  'test observe array property add': ->
    instance = new WingmanObject
    added = []
    instance.observe 'users', 'add', (newValue) -> added.push(newValue)
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
    context.observe 'user.notifications', 'add', (newValue) -> added.push(newValue)
    
    user = new WingmanObject
    context.set { user }
    user.set notifications: []
    context.get('user.notifications').push 'Hello'
    
    @assertEqual 'Hello', added[0]
  
  'test deeply nested observe of array add of yet to be set properties': ->
    context = new WingmanObject
    shared = new WingmanObject
    added = []
    context.observe 'shared.currentUser.notifications', 'add', (newValue) -> added.push(newValue)
  
    context.set { shared }
    
    currentUser = new WingmanObject
    currentUser.set notifications: []
    shared.set { currentUser }
    
    context.get('shared.currentUser.notifications').push 'Hello'
    @assertEqual 'Hello', added[0]
    
  'test observe array property remove': ->
    country = new WingmanObject
    country.set cities: ['London', 'Manchester']
    removedValueFromCallback = ''
    country.observe 'cities', 'remove', (removedValue) -> removedValueFromCallback = removedValue
    country.get('cities').remove 'London'
  
    @assertEqual 'London', removedValueFromCallback
    @assertEqual 'Manchester', country.get('cities')[0]
    @assertEqual 1, country.get('cities').length
  
  'test observe nested array property': ->
    country = new WingmanObject
    country.set cities: ['London', 'Manchester']
    user = new WingmanObject
    user.set {country}
  
    result = ''
    user.observe 'country.cities', 'add', (newValue) -> result = newValue
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
  
    onlyCode = country.toJSON(only: 'code')
  
    @assertEqual 'dk', onlyCode.code
    @assertEqual 1, Object.keys(onlyCode).length
    
    onlyCodeAndRegion = country.toJSON(only: ['code', 'region'])
  
    @assertEqual 'dk', onlyCodeAndRegion.code
    @assertEqual 'eu', onlyCodeAndRegion.region
    @assertEqual 2, Object.keys(onlyCodeAndRegion).length
  
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
    valuesFromCallback = []
    context.observeOnce 'name', (value) -> valuesFromCallback.push(value)
    
    context.set name: 'Rasmus'
    context.set name: 'Lou Bega'
    context.set name: 'Hendrix'
    
    @assertEqual 1, valuesFromCallback.length
    @assertEqual 'Rasmus', valuesFromCallback[0]
  
  'test observe once in combination with normal observe': ->
    context = new WingmanObject
    context.observeOnce 'name', -> 'test'
    callbackFired = false
    context.observe 'name', -> callbackFired = true
    context.set name: 'Rasmus'
    @assert callbackFired
  
  'test intelligent properties and json export': ->
    class Thingamabob
    thingamabob = new Thingamabob

    context = new WingmanObject
    context.set
      name: 'Guybrush'
      age: 25
      engine: thingamabob
    
    json = context.toJSON()
    
    @assertEqual 2, Object.keys(json).length
    @assertEqual 'Guybrush', json.name
    @assertEqual 25, json.age
