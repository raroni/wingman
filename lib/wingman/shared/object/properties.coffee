data = []
instances = []

findOrCreate = (object) ->
  find(object) || create(object)

find = (object) ->
  id = instances.indexOf object
  data[id]

create = (object) ->
  hash = {}
  data.push hash
  instances.push object
  hash

module.exports = { findOrCreate, find, create }
