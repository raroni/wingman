module.exports =
  assertDOMElementHasClass: (element, class_name) ->
    @assert element.className.split(' ').indexOf(class_name) != -1
