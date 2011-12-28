module.exports = class
  constructor: (@element_data, @scope, @context, @NodeInterpreter, @document) ->
    element = @document.createElement @element_data.tag

    if @scope.appendChild
      @scope.appendChild element
    else
      @scope.push element
    
    if @element_data.styles
      for key, value of @element_data.styles
        element.style[key] = if value.is_dynamic
          @context.observe value.get(), (new_value) ->
            element.style[key] = new_value
          @context.get value.get()
        else
          value.get()

    if @element_data.value
      element.innerHTML = if @element_data.value.is_dynamic
        @context.observe @element_data.value.get(), (new_value) ->
          element.innerHTML = new_value
        @context.get @element_data.value.get()
      else
        @element_data.value.get()
    else if @element_data.children
      for child in @element_data.children
        new @NodeInterpreter child, element, @context, @document
    @element = element
