module.exports = class
  @convertCssPropertyFromDomToCssNotation: (property_name) ->
    property_name.replace /(-[a-z]{1})/g, (s) ->
      s[1].toUpperCase()

  constructor: (@element_data, @scope, @context) ->
    # The class_cache hash is used to indicate how many times a given class is set on an element.
    # If for instance, 'user' has been added twice it would look lice this:
    #
    # { 'user': 2 }
    #
    @class_cache = {}

    @dom_element = Template.document.createElement @element_data.tag
    @addToScope()
    @setupStyles() if @element_data.styles
    @setupClasses() if @element_data.classes

    if @element_data.value
      @setupInnerHTML()
    else if @element_data.children
      @setupChildren()

  addToScope: ->
    if @scope.appendChild
      @scope.appendChild @dom_element
    else
      @scope.push @dom_element
  
  addClass: (class_name) ->
    @class_cache[class_name] ||= 0
    @class_cache[class_name]++
    
    if @class_cache[class_name] == 1
      @dom_element.className = if @dom_element.className
       @dom_element.className.split(' ').concat(class_name).join ' '
      else
       class_name

  removeClass: (class_name) ->
    @class_cache[class_name]-- if @class_cache[class_name]
    
    if @class_cache[class_name] == 0
      reg = new RegExp '(\\s|^)' + class_name + '(\\s|$)'
      @dom_element.className = @dom_element.className.replace reg, ''

  setupClasses: ->
    for class_name in @element_data.classes
      class_name = if class_name.is_dynamic
        value = @context.get class_name.get()
        do =>
          old_class_name = value
          @context.observe class_name.get(), (new_class_name) =>
            @removeClass old_class_name
            @addClass new_class_name
            old_class_name = new_class_name
        value
      else
        class_name.get()
      @addClass class_name
  
  setStyle: (key, value) ->
    key_css_notation = @constructor.convertCssPropertyFromDomToCssNotation key
    @dom_element.style[key_css_notation] = value

  setupStyles: -> 
    for key, value of @element_data.styles
      value = if value.is_dynamic
        do (key) =>
          @context.observe value.get(), (new_value) => @setStyle key, new_value
        @context.get value.get()
      else
        value.get()
      @setStyle key, value
  
  setupInnerHTML: ->
    @dom_element.innerHTML = if @element_data.value.is_dynamic
      @context.observe @element_data.value.get(), (new_value) =>
        @dom_element.innerHTML = new_value
      @context.get @element_data.value.get()
    else
      @element_data.value.get()
  
  setupChildren: ->
    for child in @element_data.children
      new NodeInterpreter child, @dom_element, @context, @document

Template = require '../../template'
NodeInterpreter = require '../node_interpreter'
