module.exports =
  # The classCache hash is used to indicate how many times a given class is set on an element.
  # If for instance, 'user' has been added twice it would look lice this:
  #
  # { 'user': 2 }
  #
  classCache: ->
    @_classCache ||= {}
  
  addClass: (className) ->
    @classCache()[className] ||= 0
    @classCache()[className]++
    
    if @classCache()[className] == 1
      @domElement.className = if @domElement.className
       @domElement.className.split(' ').concat(className).join ' '
      else
       className
  
  removeClass: (className) ->
    @classCache()[className]-- if @classCache()[className]
    
    if @classCache()[className] == 0
      reg = new RegExp '(\\s|^)' + className + '(\\s|$)'
      @domElement.className = @domElement.className.replace reg, ''
  
  setStyle: (key, value) ->
    keyCssNotation = @convertCssPropertyFromDomToCssNotation key
    @domElement.style[keyCssNotation] = value
  
  setAttribute: (key, value) ->
    @domElement.setAttribute key, value
  
  remove: ->
    @domElement.parentNode.removeChild @domElement
  
  # This method should probably not be an instance method. I could make it a private method,
  # but that would make it hard to test - so for now, it's just an instance method.
  # Should be refactored sometime.
  convertCssPropertyFromDomToCssNotation: (propertyName) ->
    propertyName.replace /(-[a-z]{1})/g, (s) ->
      s[1].toUpperCase()
