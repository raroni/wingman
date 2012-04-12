# Introduction to Wingman

Wingman is a Javascript framework for creating single page apps. It strikes a fine balance between providing great leverage while still being easy to understand.

* Automatically updating templates
* Decoupled application structure that makes testing easy
* Great separation of concerns through MVC
* Only a handful of classes to get familiar with

At the moment Wingman is intended to be used with Coffeescript. Support for plain Javascript will be added in the future.

## Simplest application

The simplest possible Wingman application looks like this:

```coffeescript
class MyApp extends Wingman.Application

class MyApp.RootView extends Wingman.View
  templateSource: "How are you doing?"

new MyApp el: document.createElement('my_app')
```
