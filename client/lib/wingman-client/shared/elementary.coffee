module.exports =
  # The class_cache hash is used to indicate how many times a given class is set on an element.
  # If for instance, 'user' has been added twice it would look lice this:
  #
  # { 'user': 2 }
  #
  classCache: ->
    @class_cache ||= {}
  
  addClass: (class_name) ->
    @classCache()[class_name] ||= 0
    @classCache()[class_name]++
    
    if @classCache()[class_name] == 1
      @dom_element.className = if @dom_element.className
       @dom_element.className.split(' ').concat(class_name).join ' '
      else
       class_name
  
  removeClass: (class_name) ->
    @classCache()[class_name]-- if @classCache()[class_name]
    
    if @classCache()[class_name] == 0
      reg = new RegExp '(\\s|^)' + class_name + '(\\s|$)'
      @dom_element.className = @dom_element.className.replace reg, ''
  
  setStyle: (key, value) ->
    key_css_notation = @convertCssPropertyFromDomToCssNotation key
    @dom_element.style[key_css_notation] = value
  
  setAttribute: (key, value) ->
    @dom_element.setAttribute key, value
  
  # This method should probably not be an instance method. I could make it a private method,
  # but that would make it hard to test - so for now, it's just an instance method.
  # Should be refactored sometime.
  convertCssPropertyFromDomToCssNotation: (property_name) ->
    property_name.replace /(-[a-z]{1})/g, (s) ->
      s[1].toUpperCase()
