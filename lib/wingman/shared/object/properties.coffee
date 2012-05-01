data = []
instances = []

findOrCreate = (object) ->
  find(object) || create(object)

find = (object) ->
  id = instances.indexOf object
  data[id]

create = (object) ->
  prototype = if object then findOrCreate(Object.getPrototypeOf(object)) else null
  hash = Object.create prototype
  data.push hash
  instances.push object
  hash

module.exports = { findOrCreate, find, create }
