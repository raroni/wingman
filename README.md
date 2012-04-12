# Introduction to Wingman

Wingman is a Javascript framework for creating single page apps. It strikes a fine balance between providing great leverage while still being easy to understand.

Great leverage:

* Templates update automatically
* Great separation of concerns via MVC
* Decoupled application structure that makes testing very easy

Simple and easy:

* Only a handful of classes to get familiar with
* Source code very modular

At the moment Wingman is intended to be used with Coffeescript - but plain Javascript will be supported in the future.

## Simplest application

The simplest possible Wingman application looks like this:

```coffeescript
class MyApp extends Wingman.Application

class MyApp.RootView extends Wingman.View
  templateSource: "How are you doing?"

new MyApp el: document.createElement('my_app')
```
