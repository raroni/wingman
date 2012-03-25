DOMElementHasClass = (element, className) ->
  element.className.split(' ').indexOf(className) != -1

module.exports =
  assertDOMElementHasClass: (element, className) ->
    @assert DOMElementHasClass(element, className)
  
  refuteDOMElementHasClass: (element, className) ->
    @assert !DOMElementHasClass(element, className)
