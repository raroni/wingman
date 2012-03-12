DOMElementHasClass = (element, class_name) ->
  element.className.split(' ').indexOf(class_name) != -1

module.exports =
  assertDOMElementHasClass: (element, class_name) ->
    @assert DOMElementHasClass(element, class_name)
  
  refuteDOMElementHasClass: (element, class_name) ->
    @assert !DOMElementHasClass(element, class_name)
