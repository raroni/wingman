(function(window) {
  
(function(/*! Stitch !*/) {
  if (!this.require) {
    var modules = {}, cache = {}, require = function(name, root) {
      var path = expand(root, name), module = cache[path], fn;
      if (module) {
        return module.exports;
      } else if (fn = modules[path] || modules[path = expand(path, './index')]) {
        module = {id: path, exports: {}};
        try {
          cache[path] = module;
          fn(module.exports, function(name) {
            return require(name, dirname(path));
          }, module);
          return module.exports;
        } catch (err) {
          delete cache[path];
          throw err;
        }
      } else {
        throw 'module \'' + name + '\' not found';
      }
    }, expand = function(root, name) {
      var results = [], parts, part;
      if (/^\.\.?(\/|$)/.test(name)) {
        parts = [root, name].join('/').split('/');
      } else {
        parts = name.split('/');
      }
      for (var i = 0, length = parts.length; i < length; i++) {
        part = parts[i];
        if (part == '..') {
          results.pop();
        } else if (part != '.' && part != '') {
          results.push(part);
        }
      }
      return results.join('/');
    }, dirname = function(path) {
      return path.split('/').slice(0, -1).join('/');
    };
    this.require = function(name) {
      return require(name, '');
    }
    this.require.define = function(bundle) {
      for (var key in bundle)
        modules[key] = bundle[key];
    };
  }
  return this.require.define;
}).call(this)({"wingman-client": function(exports, require, module) {(function() {

  if (typeof window !== "undefined" && window !== null) {
    exports.document = window.document;
    exports.window = window;
    exports.localStorage = localStorage;
  }

  exports.request = require('./wingman-client/request');

  exports.Template = require('./wingman-client/template');

  exports.View = require('./wingman-client/view');

  exports.Model = require('./wingman-client/model');

  exports.Controller = require('./wingman-client/controller');

  exports.Application = require('./wingman-client/application');

}).call(this);
}, "wingman-client/application": function(exports, require, module) {(function() {
  var Application, Events, Fleck, Navigator, Wingman, WingmanObject,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Wingman = require('../wingman-client');

  Events = require('./shared/events');

  WingmanObject = require('./shared/object');

  Navigator = require('./shared/navigator');

  Fleck = require('fleck');

  module.exports = Application = (function(_super) {

    __extends(Application, _super);

    Application.include(Navigator);

    Application.include(Events);

    function Application(options) {
      this.handlePopStateChange = __bind(this.handlePopStateChange, this);
      this.buildController = __bind(this.buildController, this);
      var key, value, _ref;
      if (this.constructor.__super__.constructor.instance) {
        throw new Error('You cannot instantiate two Wingman apps at the same time.');
      }
      this.constructor.__super__.constructor.instance = this;
      _ref = this.constructor;
      for (key in _ref) {
        value = _ref[key];
        if (key.match("(.+)View$") && key !== 'RootView') {
          this.constructor.RootView[key] = value;
        }
      }
      this.bind('viewCreated', this.buildController);
      if (options.el != null) this.el = options.el;
      this.view = options.view || this.buildView();
      Wingman.window.addEventListener('popstate', this.handlePopStateChange);
      this.updatePath();
      if (typeof this.ready === "function") this.ready();
    }

    Application.prototype.buildView = function() {
      var view,
        _this = this;
      view = new this.constructor.RootView({
        parent: this,
        el: this.el,
        app: this
      });
      view.bind('descendantCreated', function(view) {
        return _this.trigger('viewCreated', view);
      });
      this.trigger('viewCreated', view);
      view.render();
      return view;
    };

    Application.prototype.buildController = function(view) {
      var klass_name, part, parts, scope, _i, _len;
      parts = view.path().split('.');
      scope = this.constructor;
      for (_i = 0, _len = parts.length; _i < _len; _i++) {
        part = parts[_i];
        klass_name = Fleck.camelize("" + part + "_controller", true);
        scope = scope[klass_name];
      }
      return new scope(view);
    };

    Application.prototype.handlePopStateChange = function(e) {
      if (Wingman.window.navigator.userAgent.match('WebKit') && !this._first_run) {
        return this._first_run = true;
      } else {
        this.updateNavigationOptions(e.state);
        return this.updatePath();
      }
    };

    Application.prototype.updatePath = function() {
      return this.set({
        path: Wingman.document.location.pathname.substr(1)
      });
    };

    Application.prototype.updateNavigationOptions = function(options) {
      return this.set({
        navigation_options: options
      });
    };

    Application.prototype.findView = function(path) {
      return this.view.get(path);
    };

    return Application;

  })(WingmanObject);

}).call(this);
}, "wingman-client/controller": function(exports, require, module) {(function() {
  var Navigator, Wingman, WingmanObject,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  WingmanObject = require('./shared/object');

  Wingman = require('../wingman-client');

  Navigator = require('./shared/navigator');

  module.exports = (function(_super) {

    __extends(_Class, _super);

    _Class.include(Navigator);

    function _Class(view) {
      _Class.__super__.constructor.call(this);
      this.set({
        view: view
      });
      this.set({
        app: view.app
      });
      if (typeof this.ready === "function") this.ready();
    }

    return _Class;

  })(WingmanObject);

}).call(this);
}, "wingman-client/model": function(exports, require, module) {(function() {
  var Fleck, HasManyAssociation, Model, Scope, StorageAdapter, Store, Wingman, WingmanObject,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  Wingman = require('../wingman-client');

  WingmanObject = require('./shared/object');

  StorageAdapter = require('./model/storage_adapter');

  Store = require('./model/store');

  Scope = require('./model/scope');

  HasManyAssociation = require('./model/has_many_association');

  Fleck = require('fleck');

  module.exports = Model = (function(_super) {

    __extends(Model, _super);

    Model.extend(StorageAdapter);

    Model.store = function() {
      return this._store || (this._store = new Store);
    };

    Model.count = function() {
      return this.store().count();
    };

    Model.load = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (typeof args[0] === 'number') {
        return this.loadOne(args[0], args[1]);
      } else {
        return this.loadMany(args[0]);
      }
    };

    Model.hasMany = function(name) {
      return (this.has_many_names || (this.has_many_names = [])).push(name);
    };

    Model.loadOne = function(id, callback) {
      var _this = this;
      return this.storageAdapter().load(id, {
        success: function(hash) {
          var model;
          model = new _this(hash);
          if (callback) return callback(model);
        }
      });
    };

    Model.loadMany = function(callback) {
      var _this = this;
      return this.storageAdapter().load({
        success: function(array) {
          var model, model_data, models, _i, _len;
          models = [];
          for (_i = 0, _len = array.length; _i < _len; _i++) {
            model_data = array[_i];
            model = new _this(model_data);
            models.push(model);
          }
          if (callback) return callback(models);
        }
      });
    };

    Model.scoped = function(params) {
      return new Scope(this.store(), params);
    };

    function Model(properties, options) {
      var _this = this;
      this.storage_adapter = this.constructor.storageAdapter();
      this.dirty_static_property_names = [];
      if (this.constructor.has_many_names) this.setupHasManyAssociations();
      this.observeOnce('id', function() {
        return _this.constructor.store().add(_this);
      });
      this.set(properties);
    }

    Model.prototype.setupHasManyAssociations = function() {
      var association, has_many_name, klass, klass_name, _i, _len, _ref, _results,
        _this = this;
      _ref = this.constructor.has_many_names;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        has_many_name = _ref[_i];
        klass_name = Fleck.camelize(Fleck.singularize(has_many_name), true);
        klass = Wingman.Application.instance.constructor[klass_name];
        association = new HasManyAssociation(this, klass);
        this.setProperty(has_many_name, association);
        association.bind('add', function(model) {
          return _this.trigger("add:" + has_many_name, model);
        });
        _results.push(association.bind('remove', function(model) {
          return _this.trigger("remove:" + has_many_name, model);
        }));
      }
      return _results;
    };

    Model.prototype.save = function(options) {
      var operation,
        _this = this;
      if (options == null) options = {};
      operation = this.isPersisted() ? 'update' : 'create';
      return this.storage_adapter[operation](this, {
        success: function(data) {
          if (data) {
            if (operation === 'update') delete data.id;
            _this.set(data);
          }
          _this.clean();
          return typeof options.success === "function" ? options.success() : void 0;
        },
        error: function() {
          return typeof options.error === "function" ? options.error() : void 0;
        }
      });
    };

    Model.prototype.destroy = function() {
      this.trigger('destroy', this);
      return this.storage_adapter["delete"](this.get('id'));
    };

    Model.prototype.toParam = function() {
      return this.get('id');
    };

    Model.prototype.load = function() {
      var _this = this;
      return this.storage_adapter.load(this.get('id'), {
        success: function(hash) {
          delete hash.id;
          return _this.set(hash);
        }
      });
    };

    Model.prototype.clean = function() {
      return this.dirty_static_property_names.length = 0;
    };

    Model.prototype.dirtyStaticProperties = function() {
      return this.toJSON({
        only: this.dirty_static_property_names
      });
    };

    Model.prototype.set = function(hash) {
      return Model.__super__.set.call(this, hash);
    };

    Model.prototype.setProperty = function(property_name, values) {
      if (property_name === 'id' && this.get('id')) {
        throw new Error('You cannot change the ID of a model when set.');
      }
      this.dirty_static_property_names.push(property_name);
      Model.__super__.setProperty.call(this, property_name, values);
      if (this.storage_adapter.auto_save) return this.save();
    };

    Model.prototype.isPersisted = function() {
      return !!this.get('id');
    };

    Model.prototype.isDirty = function() {
      return this.dirty_static_property_names.length !== 0;
    };

    return Model;

  })(WingmanObject);

}).call(this);
}, "wingman-client/model/has_many_association": function(exports, require, module) {(function() {
  var Events, Fleck, HasManyAssociation, Module,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  Fleck = require('fleck');

  Module = require('./../shared/module');

  Events = require('./../shared/events');

  module.exports = HasManyAssociation = (function(_super) {

    __extends(HasManyAssociation, _super);

    HasManyAssociation.include(Events);

    function HasManyAssociation(model, associated_class) {
      this.model = model;
      this.associated_class = associated_class;
      this.setupScope = __bind(this.setupScope, this);
      this.model.observeOnce('id', this.setupScope);
    }

    HasManyAssociation.prototype.setupScope = function() {
      var _this = this;
      this.scope = this.associated_class.scoped(this.scopeOptions());
      this.scope.forEach(function(model) {
        return _this.trigger('add', model);
      });
      this.scope.bind('add', function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return _this.trigger.apply(_this, ['add'].concat(__slice.call(args)));
      });
      return this.scope.bind('remove', function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return _this.trigger.apply(_this, ['remove'].concat(__slice.call(args)));
      });
    };

    HasManyAssociation.prototype.scopeOptions = function() {
      var options;
      options = {};
      options[this.foreignKey()] = this.model.get('id');
      return options;
    };

    HasManyAssociation.prototype.foreignKey = function() {
      return Fleck.underscore(this.model.constructor.name) + '_id';
    };

    HasManyAssociation.prototype.count = function() {
      if (this.scope) {
        return this.scope.count();
      } else {
        return 0;
      }
    };

    HasManyAssociation.prototype.forEach = function(callback) {
      var model, _i, _len, _ref, _results;
      _ref = this.models();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        model = _ref[_i];
        _results.push(callback(model));
      }
      return _results;
    };

    HasManyAssociation.prototype.models = function() {
      var key, models, value, _ref;
      if (this.scope) {
        models = [];
        _ref = this.scope.models;
        for (key in _ref) {
          value = _ref[key];
          models.push(value);
        }
        return models;
      } else {
        return [];
      }
    };

    return HasManyAssociation;

  })(Module);

}).call(this);
}, "wingman-client/model/scope": function(exports, require, module) {(function() {
  var Events, Module, Scope,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Module = require('./../shared/module');

  Events = require('./../shared/events');

  module.exports = Scope = (function(_super) {

    __extends(Scope, _super);

    Scope.include(Events);

    function Scope(store, params) {
      var _this = this;
      this.params = params;
      this.remove = __bind(this.remove, this);
      this.check = __bind(this.check, this);
      this.listen = __bind(this.listen, this);
      this.models = {};
      store.forEach(function(model) {
        return _this.check(model);
      });
      store.bind('add', this.listen);
    }

    Scope.prototype.listen = function(model) {
      var key, _i, _len, _ref, _results,
        _this = this;
      this.check(model);
      _ref = Object.keys(this.params);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        key = _ref[_i];
        _results.push(model.observe(key, function() {
          return _this.check(model);
        }));
      }
      return _results;
    };

    Scope.prototype.check = function(model) {
      if (this.shouldBeAdded(model)) {
        return this.add(model);
      } else if (this.shouldBeRemoved(model)) {
        return this.remove(model);
      }
    };

    Scope.prototype.shouldBeAdded = function(model) {
      return this.matches(model) && !this.exists(model);
    };

    Scope.prototype.shouldBeRemoved = function(model) {
      return !this.matches(model) && this.exists(model);
    };

    Scope.prototype.add = function(model) {
      if (!model.get('id')) throw new Error('Model must have ID to be stored.');
      if (this.exists(model)) {
        throw new Error("" + model.constructor.name + " model with ID " + (model.get('id')) + " already in scope.");
      }
      this.models[model.get('id')] = model;
      this.trigger('add', model);
      return model.bind('destroy', this.remove);
    };

    Scope.prototype.matches = function(model) {
      var _this = this;
      return Object.keys(this.params).every(function(key) {
        return model.get(key) === _this.params[key];
      });
    };

    Scope.prototype.count = function() {
      return Object.keys(this.models).length;
    };

    Scope.prototype.find = function(id) {
      return this.models[id] || (function() {
        throw new Error('Model not found in scope.');
      })();
    };

    Scope.prototype.remove = function(model) {
      delete this.models[model.get('id')];
      model.unbind('destroy', this.remove);
      return this.trigger('remove', model);
    };

    Scope.prototype.exists = function(model) {
      return !!this.models[model.get('id')];
    };

    Scope.prototype.forEach = function(callback) {
      var key, value, _ref, _results;
      _ref = this.models;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        _results.push(callback(value));
      }
      return _results;
    };

    return Scope;

  })(Module);

}).call(this);
}, "wingman-client/model/storage_adapter": function(exports, require, module) {(function() {
  var LocalStorage, RestStorage;

  RestStorage = require('./storage_adapters/rest');

  LocalStorage = require('./storage_adapters/local');

  module.exports = {
    storage_types: {
      'rest': RestStorage,
      'local': LocalStorage
    },
    storage: function(type, options) {
      if (options == null) options = {};
      if (!this.storageAdapterTypeSupported(type)) {
        throw new Error("Storage engine " + type + " not supported.");
      }
      options.type = type;
      return this.storage_adapter_options = options;
    },
    storageAdapterTypeSupported: function(type) {
      return !!this.storage_types[type];
    },
    storageAdapter: function() {
      return this.storage_adapter || (this.storage_adapter = this.buildStorageAdapter());
    },
    buildStorageAdapter: function() {
      var key, klass, options, value, _ref;
      this.storage_adapter_options || (this.storage_adapter_options = {
        type: 'rest'
      });
      klass = this.storage_types[this.storage_adapter_options.type];
      options = {};
      _ref = this.storage_adapter_options;
      for (key in _ref) {
        value = _ref[key];
        if (key !== 'type') options[key] = value;
      }
      return new klass(options);
    }
  };

}).call(this);
}, "wingman-client/model/storage_adapters/local": function(exports, require, module) {(function() {
  var Wingman;

  Wingman = require('../../../wingman-client');

  module.exports = (function() {

    _Class.prototype.auto_save = true;

    function _Class(options) {
      this.options = options;
    }

    _Class.prototype.create = function(model, options) {
      model.set({
        id: this.generateId()
      });
      Wingman.localStorage.setItem(this.key(model.get('id')), JSON.stringify(model.toJSON()));
      return options != null ? typeof options.success === "function" ? options.success() : void 0 : void 0;
    };

    _Class.prototype.update = function(model, options) {
      var _this = this;
      return this.load(model.get('id'), {
        success: function(existing_properties) {
          var key, new_properties, value;
          new_properties = model.toJSON();
          for (key in existing_properties) {
            value = existing_properties[key];
            if (new_properties[key] == null) new_properties[key] = value;
          }
          Wingman.localStorage.setItem(_this.key(model.get('id')), JSON.stringify(new_properties));
          return options != null ? typeof options.success === "function" ? options.success() : void 0 : void 0;
        }
      });
    };

    _Class.prototype.load = function(id, options) {
      var item_as_json, item_as_string;
      item_as_string = Wingman.localStorage.getItem(this.key(id));
      item_as_json = JSON.parse(item_as_string);
      return options.success(item_as_json);
    };

    _Class.prototype.key = function(id) {
      return [this.options.namespace, id].join('.');
    };

    _Class.prototype.generateId = function() {
      return Math.round(Math.random() * 5000000);
    };

    return _Class;

  })();

}).call(this);
}, "wingman-client/model/storage_adapters/rest": function(exports, require, module) {(function() {
  var Wingman,
    __slice = Array.prototype.slice;

  Wingman = require('../../../wingman-client');

  module.exports = (function() {

    function _Class(options) {
      this.options = options;
    }

    _Class.prototype.create = function(model, options) {
      if (options == null) options = {};
      return Wingman.request({
        type: 'POST',
        url: this.options.url,
        data: model.dirtyStaticProperties(),
        error: options.error,
        success: options.success
      });
    };

    _Class.prototype.update = function(model, options) {
      if (options == null) options = {};
      return Wingman.request({
        type: 'PUT',
        url: "" + this.options.url + "/" + (model.get('id')),
        data: model.dirtyStaticProperties(),
        error: options.error,
        success: options.success
      });
    };

    _Class.prototype.load = function() {
      var args, options;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (args.length === 2) {
        options = args[1];
        options.url = [this.options.url, args[0]].join('/');
      } else {
        options = args[0];
        options.url = this.options.url;
      }
      options.type = 'GET';
      return Wingman.request(options);
    };

    _Class.prototype["delete"] = function(id) {
      return Wingman.request({
        url: [this.options.url, id].join('/'),
        type: 'DELETE'
      });
    };

    return _Class;

  })();

}).call(this);
}, "wingman-client/model/store": function(exports, require, module) {(function() {
  var Events, Module, Store,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Module = require('./../shared/module');

  Events = require('./../shared/events');

  module.exports = Store = (function(_super) {

    __extends(Store, _super);

    Store.include(Events);

    function Store() {
      this.remove = __bind(this.remove, this);      this.models = {};
    }

    Store.prototype.add = function(model) {
      if (!model.get('id')) throw new Error('Model must have ID to be stored.');
      if (this.exists(model)) {
        return this.update(this.models[model.get('id')], model);
      } else {
        return this.insert(model);
      }
    };

    Store.prototype.insert = function(model) {
      this.models[model.get('id')] = model;
      this.trigger('add', model);
      return model.bind('destroy', this.remove);
    };

    Store.prototype.update = function(model, model2) {
      var key, value, _ref, _results;
      _ref = model2.toJSON();
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        if (key !== 'id') {
          _results.push(model.setProperty(key, value));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Store.prototype.count = function() {
      return Object.keys(this.models).length;
    };

    Store.prototype.remove = function(model) {
      delete this.models[model.get('id')];
      model.unbind(this.remove);
      return this.trigger('remove', model);
    };

    Store.prototype.exists = function(model) {
      return !!this.models[model.get('id')];
    };

    Store.prototype.forEach = function(callback) {
      var key, value, _ref, _results;
      _ref = this.models;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        _results.push(callback(value));
      }
      return _results;
    };

    return Store;

  })(Module);

}).call(this);
}, "wingman-client/request": function(exports, require, module) {(function() {
  var Wingman, request,
    __slice = Array.prototype.slice;

  Wingman = require('../wingman-client');

  request = function() {
    var args, _base, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (((_ref = Wingman.Application.instance) != null ? _ref.host : void 0) != null) {
      args[0].url = ['http://', Wingman.Application.instance.host, args[0].url].join('');
    }
    (_base = args[0]).dataType || (_base.dataType = 'json');
    return request.realRequest.apply(request, args);
  };

  if (typeof jQuery !== "undefined" && jQuery !== null) {
    request.realRequest = jQuery.ajax;
  }

  module.exports = request;

}).call(this);
}, "wingman-client/shared/elementary": function(exports, require, module) {(function() {

  module.exports = {
    classCache: function() {
      return this.class_cache || (this.class_cache = {});
    },
    addClass: function(class_name) {
      var _base;
      (_base = this.classCache())[class_name] || (_base[class_name] = 0);
      this.classCache()[class_name]++;
      if (this.classCache()[class_name] === 1) {
        return this.dom_element.className = this.dom_element.className ? this.dom_element.className.split(' ').concat(class_name).join(' ') : class_name;
      }
    },
    removeClass: function(class_name) {
      var reg;
      if (this.classCache()[class_name]) this.classCache()[class_name]--;
      if (this.classCache()[class_name] === 0) {
        reg = new RegExp('(\\s|^)' + class_name + '(\\s|$)');
        return this.dom_element.className = this.dom_element.className.replace(reg, '');
      }
    },
    setStyle: function(key, value) {
      var key_css_notation;
      key_css_notation = this.convertCssPropertyFromDomToCssNotation(key);
      return this.dom_element.style[key_css_notation] = value;
    },
    setAttribute: function(key, value) {
      return this.dom_element.setAttribute(key, value);
    },
    remove: function() {
      return this.dom_element.parentNode.removeChild(this.dom_element);
    },
    convertCssPropertyFromDomToCssNotation: function(property_name) {
      return property_name.replace(/(-[a-z]{1})/g, function(s) {
        return s[1].toUpperCase();
      });
    }
  };

}).call(this);
}, "wingman-client/shared/events": function(exports, require, module) {(function() {
  var __slice = Array.prototype.slice;

  module.exports = {
    bind: function(event_name, callback) {
      var _base;
      if (!callback) throw new Error('Callback must be set!');
      this._callbacks || (this._callbacks = {});
      (_base = this._callbacks)[event_name] || (_base[event_name] = []);
      this._callbacks[event_name].push(callback);
      return this._callbacks;
    },
    unbind: function(event_name, callback) {
      var index, list;
      list = this._callbacks && this._callbacks[event_name];
      if (!list) return false;
      index = list.indexOf(callback);
      return list.splice(index, 1);
    },
    trigger: function() {
      var args, callback, event_name, list, _i, _len, _ref, _results;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      event_name = args.shift();
      list = this._callbacks && this._callbacks[event_name];
      if (!list) return;
      _ref = list.slice();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        _results.push(callback.apply(this, args));
      }
      return _results;
    }
  };

}).call(this);
}, "wingman-client/shared/module": function(exports, require, module) {(function() {

  module.exports = (function() {

    function _Class() {}

    _Class.include = function(obj) {
      var key, value;
      if (!obj) throw 'Module.include requires obj';
      for (key in obj) {
        value = obj[key];
        this.prototype[key] = value;
      }
      return typeof obj.included === "function" ? obj.included(this) : void 0;
    };

    _Class.extend = function(obj) {
      var key, value;
      if (!obj) throw 'Module.extend requires obj';
      for (key in obj) {
        value = obj[key];
        this[key] = value;
      }
      return typeof obj.extended === "function" ? obj.extended(this) : void 0;
    };

    return _Class;

  })();

}).call(this);
}, "wingman-client/shared/navigator": function(exports, require, module) {(function() {
  var Wingman;

  Wingman = require('../../wingman-client');

  module.exports = {
    navigate: function(location, options) {
      if (options == null) options = {};
      Wingman.window.history.pushState(options, '', "/" + location);
      Wingman.Application.instance.updateNavigationOptions(options);
      return Wingman.Application.instance.updatePath();
    },
    back: function(times) {
      if (times == null) times = 1;
      return Wingman.window.history.go(-times);
    }
  };

}).call(this);
}, "wingman-client/shared/object": function(exports, require, module) {(function() {
  var Events, Module, WingmanObject, property_dependencies,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice,
    __indexOf = Array.prototype.indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Module = require('./module');

  Events = require('./events');

  property_dependencies = {};

  WingmanObject = WingmanObject = (function(_super) {

    __extends(WingmanObject, _super);

    WingmanObject.include(Events);

    WingmanObject.parentPropertyDependencies = function() {
      var _ref, _ref2;
      if ((_ref = this.__super__) != null ? (_ref2 = _ref.constructor) != null ? _ref2.propertyDependencies : void 0 : void 0) {
        return this.__super__.constructor.propertyDependencies();
      } else {
        return {};
      }
    };

    WingmanObject.buildPropertyDependencies = function() {
      var dependencies, key, value, _ref;
      dependencies = {};
      _ref = this.parentPropertyDependencies();
      for (key in _ref) {
        value = _ref[key];
        dependencies[key] = value;
      }
      return dependencies;
    };

    WingmanObject.propertyDependencies = function(hash) {
      if (hash) {
        return this.addPropertyDependencies(hash);
      } else {
        return property_dependencies[this] || (property_dependencies[this] = this.buildPropertyDependencies());
      }
    };

    WingmanObject.addPropertyDependencies = function(hash) {
      var config, key, value, _results;
      config = this.propertyDependencies();
      _results = [];
      for (key in hash) {
        value = hash[key];
        _results.push(config[key] = value);
      }
      return _results;
    };

    function WingmanObject() {
      if (this.constructor.propertyDependencies()) this.initPropertyDependencies();
    }

    WingmanObject.prototype.initPropertyDependencies = function() {
      var dependent_property_key, depending_properties_keys, depending_property_key, _ref, _results;
      _ref = this.constructor.propertyDependencies();
      _results = [];
      for (dependent_property_key in _ref) {
        depending_properties_keys = _ref[dependent_property_key];
        if (!Array.isArray(depending_properties_keys)) {
          depending_properties_keys = [depending_properties_keys];
        }
        _results.push((function() {
          var _i, _len, _results2;
          _results2 = [];
          for (_i = 0, _len = depending_properties_keys.length; _i < _len; _i++) {
            depending_property_key = depending_properties_keys[_i];
            _results2.push(this.initPropertyDependency(dependent_property_key, depending_property_key));
          }
          return _results2;
        }).call(this));
      }
      return _results;
    };

    WingmanObject.prototype.initPropertyDependency = function(dependent_property_key, depending_property_key) {
      var observeArrayLike, trigger, unobserveArrayLike,
        _this = this;
      trigger = function() {
        return _this.triggerPropertyChange(dependent_property_key);
      };
      this.observe(depending_property_key, function(new_value, old_value) {
        trigger();
        if (!(old_value != null ? old_value.forEach : void 0) && (new_value != null ? new_value.forEach : void 0)) {
          return observeArrayLike();
        } else if (old_value != null ? old_value.forEach : void 0) {
          return unobserveArrayLike();
        }
      });
      observeArrayLike = function() {
        _this.observe(depending_property_key, 'add', trigger);
        return _this.observe(depending_property_key, 'remove', trigger);
      };
      return unobserveArrayLike = function() {
        _this.unobserve(depending_property_key, 'add', trigger);
        return _this.unobserve(depending_property_key, 'remove', trigger);
      };
    };

    WingmanObject.prototype.set = function(hash) {
      return this.setProperties(hash);
    };

    WingmanObject.prototype.setProperties = function(hash) {
      var property_name, value, _results;
      _results = [];
      for (property_name in hash) {
        value = hash[property_name];
        _results.push(this.setProperty(property_name, value));
      }
      return _results;
    };

    WingmanObject.prototype.triggerPropertyChange = function(property_name) {
      var new_value;
      this.previous_properties || (this.previous_properties = {});
      new_value = this.get(property_name);
      if (!this.previous_properties.hasOwnProperty(property_name) || this.previous_properties[property_name] !== new_value) {
        this.trigger("change:" + property_name, new_value, this.previous_properties[property_name]);
        return this.previous_properties[property_name] = new_value;
      }
    };

    WingmanObject.prototype.observeOnce = function(chain_as_string, callback) {
      var observer,
        _this = this;
      observer = function() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        callback.apply(null, args);
        return _this.unobserve(chain_as_string, observer);
      };
      return this.observe(chain_as_string, observer);
    };

    WingmanObject.prototype.observe = function() {
      var args, callback, chain, chain_as_string, chain_except_first, chain_except_first_as_string, get_and_send_to_callback, nested, observeOnNested, observe_type, property, type,
        _this = this;
      chain_as_string = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      callback = args.pop();
      type = args.pop() || 'change';
      chain = chain_as_string.split('.');
      chain_except_first = chain.slice(1, chain.length);
      chain_except_first_as_string = chain_except_first.join('.');
      nested = chain_except_first.length !== 0;
      get_and_send_to_callback = function(new_value, old_value) {
        if (type === 'change') {
          return callback(new_value, old_value);
        } else {
          return callback(new_value);
        }
      };
      property = this.get(chain[0]);
      observeOnNested = function(p) {
        return p.observe(chain_except_first_as_string, type, function(new_value, old_value) {
          return get_and_send_to_callback(new_value, old_value);
        });
      };
      if (nested && property) observeOnNested(property);
      observe_type = nested ? 'change' : type;
      return this.observeProperty(chain[0], observe_type, function(new_value, old_value) {
        var ov;
        if (nested) {
          if (new_value) {
            ov = old_value ? old_value.get(chain_except_first.join('.')) : void 0;
            if (type === 'change') {
              get_and_send_to_callback(new_value.get(chain_except_first.join('.')), ov);
            }
            observeOnNested(new_value);
          }
          if (old_value) {
            return old_value.unobserve(chain_except_first_as_string, type, get_and_send_to_callback);
          }
        } else {
          return get_and_send_to_callback(new_value, old_value);
        }
      });
    };

    WingmanObject.prototype.observeProperty = function(property_name, type, callback) {
      return this.bind("" + type + ":" + property_name, callback);
    };

    WingmanObject.prototype.unobserve = function() {
      var args, callback, property_name, type;
      property_name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      callback = args.pop();
      type = args.pop() || 'change';
      return this.unbind("" + type + ":" + property_name, callback);
    };

    WingmanObject.prototype.setProperty = function(property_name, value) {
      var i, parent, _len, _ref;
      value = this.convertIfNecessary(value);
      this.registerPropertySet(property_name);
      this[property_name] = value;
      this.triggerPropertyChange(property_name);
      parent = this;
      if (Array.isArray(this[property_name])) {
        _ref = this[property_name];
        for (i = 0, _len = _ref.length; i < _len; i++) {
          value = _ref[i];
          this[property_name][i] = this.convertIfNecessary(value);
        }
        return this.addTriggersToArray(property_name);
      }
    };

    WingmanObject.prototype.registerPropertySet = function(property_name) {
      return this.setPropertyNames().push(property_name);
    };

    WingmanObject.prototype.setPropertyNames = function() {
      return this.set_property_names || (this.set_property_names = []);
    };

    WingmanObject.prototype.get = function(chain_as_string) {
      var chain, nested_property, nested_property_name;
      chain = chain_as_string.split('.');
      if (chain.length === 1) {
        return this.getProperty(chain[0]);
      } else {
        nested_property_name = chain.shift();
        nested_property = this.getProperty(nested_property_name);
        if (nested_property) {
          return nested_property.get(chain.join('.'));
        } else {
          return;
        }
      }
    };

    WingmanObject.prototype.getProperty = function(property_name) {
      if (typeof this[property_name] === 'function') {
        return this[property_name].apply(this);
      } else {
        return this[property_name];
      }
    };

    WingmanObject.prototype.toJSON = function(options) {
      var json, property_name, should_be_included, _i, _len, _ref;
      if (options == null) options = {};
      if (options.only && !Array.isArray(options.only)) {
        options.only = [options.only];
      }
      json = {};
      _ref = this.setPropertyNames();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        property_name = _ref[_i];
        should_be_included = (!options.only || (__indexOf.call(options.only, property_name) >= 0)) && this.serializable(this.get(property_name));
        if (should_be_included) json[property_name] = this.get(property_name);
      }
      return json;
    };

    WingmanObject.prototype.serializable = function(value) {
      var _ref;
      return ((_ref = typeof value) === 'number' || _ref === 'string') || this.convertable(value);
    };

    WingmanObject.prototype.convertIfNecessary = function(value) {
      var wo;
      if (this.convertable(value)) {
        wo = new WingmanObject;
        wo.set(value);
        return wo;
      } else {
        return value;
      }
    };

    WingmanObject.prototype.convertable = function(value) {
      return typeof value === 'object' && ((value != null ? value.constructor : void 0) != null) && value.constructor.name === 'Object' && (!(value instanceof WingmanObject)) && !((value != null ? value._ownerDocument : void 0) != null);
    };

    WingmanObject.prototype.addTriggersToArray = function(property_name) {
      var array, parent;
      parent = this;
      array = this[property_name];
      array.push = function() {
        Array.prototype.push.apply(this, arguments);
        return parent.trigger("add:" + property_name, arguments['0']);
      };
      return array.remove = function(value) {
        var index;
        index = this.indexOf(value);
        if (index !== -1) {
          this.splice(index, 1);
          return parent.trigger("remove:" + property_name, value);
        }
      };
    };

    return WingmanObject;

  })(Module);

  module.exports = WingmanObject;

}).call(this);
}, "wingman-client/template": function(exports, require, module) {(function() {
  var Fleck, NodeFactory, Parser, Template;

  module.exports = Template = (function() {

    Template.compile = function(source) {
      var template;
      template = new this(source);
      return function(el, context) {
        return template.evaluate(el, context);
      };
    };

    function Template(source) {
      this.tree = Parser.parse(source);
    }

    Template.prototype.evaluate = function(el, context) {
      var node_data, _i, _len, _ref, _results;
      _ref = this.tree.children;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node_data = _ref[_i];
        _results.push(NodeFactory.create(node_data, el, context));
      }
      return _results;
    };

    return Template;

  })();

  Parser = require('./template/parser');

  NodeFactory = require('./template/node_factory');

  Fleck = require('fleck');

}).call(this);
}, "wingman-client/template/node_factory": function(exports, require, module) {(function() {
  var ChildView, Conditional, Element, ForBlock;

  exports.create = function(node_data, scope, context) {
    this.node_data = node_data;
    this.scope = scope;
    this.context = context;
    if (this.node_data.type === 'for') {
      return new ForBlock(this.node_data, this.scope, this.context);
    } else if (this.node_data.type === 'child_view') {
      return new ChildView(this.node_data, this.scope, this.context);
    } else if (this.node_data.type === 'conditional') {
      return new Conditional(this.node_data, this.scope, this.context);
    } else {
      return new Element(this.node_data, this.scope, this.context);
    }
  };

  ForBlock = require('./node_factory/for_block');

  ChildView = require('./node_factory/child_view');

  Conditional = require('./node_factory/conditional');

  Element = require('./node_factory/element');

}).call(this);
}, "wingman-client/template/node_factory/child_view": function(exports, require, module) {(function() {
  var ChildView;

  module.exports = ChildView = (function() {

    function ChildView(node_data, scope, context) {
      var element;
      this.node_data = node_data;
      this.scope = scope;
      this.context = context;
      this.view = this.context.createChildView(this.node_data.name);
      if (this.context.get(this.node_data.name)) {
        this.view.setProperty(this.node_data.name, this.context.get(this.node_data.name));
      }
      element = this.view.el;
      this.scope.appendChild(element);
    }

    ChildView.prototype.remove = function() {
      return this.view.remove();
    };

    return ChildView;

  })();

}).call(this);
}, "wingman-client/template/node_factory/conditional": function(exports, require, module) {(function() {
  var Conditional, NodeFactory,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  NodeFactory = require('../node_factory');

  module.exports = Conditional = (function() {

    function Conditional(node_data, scope, context) {
      this.node_data = node_data;
      this.scope = scope;
      this.context = context;
      this.update = __bind(this.update, this);
      this.nodes = [];
      this.context.observe(this.node_data.source, this.update);
      this.update(this.context.get(this.node_data.source));
    }

    Conditional.prototype.add = function(current_value) {
      var new_node_data, node, _i, _j, _len, _len2, _ref, _ref2, _results, _results2;
      if (current_value) {
        _ref = this.node_data.true_children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          new_node_data = _ref[_i];
          node = NodeFactory.create(new_node_data, this.scope, this.context);
          _results.push(this.nodes.push(node));
        }
        return _results;
      } else if (this.node_data.false_children) {
        _ref2 = this.node_data.false_children;
        _results2 = [];
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          new_node_data = _ref2[_j];
          node = NodeFactory.create(new_node_data, this.scope, this.context);
          _results2.push(this.nodes.push(node));
        }
        return _results2;
      }
    };

    Conditional.prototype.remove = function() {
      var node, _results;
      _results = [];
      while (node = this.nodes.shift()) {
        _results.push(node.remove());
      }
      return _results;
    };

    Conditional.prototype.update = function(current_value) {
      this.remove();
      return this.add(current_value);
    };

    return Conditional;

  })();

}).call(this);
}, "wingman-client/template/node_factory/element": function(exports, require, module) {(function() {
  var Element, Elementary, Module, NodeFactory, Wingman,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Module = require('../../shared/module');

  Elementary = require('../../shared/elementary');

  module.exports = Element = (function(_super) {

    __extends(Element, _super);

    Element.include(Elementary);

    function Element(element_data, scope, context) {
      this.element_data = element_data;
      this.scope = scope;
      this.context = context;
      this.dom_element = Wingman.document.createElement(this.element_data.tag);
      this.addToScope();
      if (this.element_data.styles) this.setupStyles();
      if (this.element_data.classes) this.setupClasses();
      if (this.element_data.attributes) this.setupAttributes();
      if (this.element_data.value) {
        this.setupInnerHTML();
      } else if (this.element_data.children) {
        this.setupChildren();
      }
    }

    Element.prototype.addToScope = function() {
      return this.scope.appendChild(this.dom_element);
    };

    Element.prototype.setupClasses = function() {
      var class_name, _i, _len, _ref, _results;
      _ref = this.element_data.classes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        class_name = _ref[_i];
        if (class_name.is_dynamic) this.observeClass(class_name);
        _results.push(this.addClass(class_name.get(this.context)));
      }
      return _results;
    };

    Element.prototype.setupAttributes = function() {
      var key, value, _ref, _results;
      _ref = this.element_data.attributes;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        this.setAttribute(key, value.get(this.context));
        if (value.is_dynamic) {
          _results.push(this.observeAttribute(key, value));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Element.prototype.observeAttribute = function(key, value) {
      var _this = this;
      return this.context.observe(value.get(), function(new_value) {
        return _this.setAttribute(key, new_value);
      });
    };

    Element.prototype.observeClass = function(class_name) {
      var _this = this;
      return this.context.observe(class_name.get(), function(new_class_name, old_class_name) {
        _this.removeClass(old_class_name);
        return _this.addClass(new_class_name);
      });
    };

    Element.prototype.setupStyles = function() {
      var key, value, _ref, _results;
      _ref = this.element_data.styles;
      _results = [];
      for (key in _ref) {
        value = _ref[key];
        if (value.is_dynamic) this.observeStyle(key, value);
        _results.push(this.setStyle(key, value.get(this.context)));
      }
      return _results;
    };

    Element.prototype.observeStyle = function(key, value) {
      var _this = this;
      return this.context.observe(value.get(), function(new_value) {
        return _this.setStyle(key, new_value);
      });
    };

    Element.prototype.setupInnerHTML = function() {
      var _this = this;
      return this.dom_element.innerHTML = this.element_data.value.is_dynamic ? (this.context.observe(this.element_data.value.get(), function(new_value) {
        return _this.dom_element.innerHTML = new_value;
      }), this.context.get(this.element_data.value.get())) : this.element_data.value.get();
    };

    Element.prototype.setupChildren = function() {
      var child, _i, _len, _ref, _results;
      _ref = this.element_data.children;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        _results.push(NodeFactory.create(child, this.dom_element, this.context));
      }
      return _results;
    };

    return Element;

  })(Module);

  Wingman = require('../../../wingman-client');

  NodeFactory = require('../node_factory');

}).call(this);
}, "wingman-client/template/node_factory/for_block": function(exports, require, module) {(function() {
  var Fleck, ForBlock, NodeFactory, WingmanObject,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  WingmanObject = require('../../shared/object');

  Fleck = require('fleck');

  NodeFactory = require('../node_factory');

  module.exports = ForBlock = (function() {

    function ForBlock(node_data, scope, context) {
      this.node_data = node_data;
      this.scope = scope;
      this.context = context;
      this.rebuild = __bind(this.rebuild, this);
      this.remove = __bind(this.remove, this);
      this.add = __bind(this.add, this);
      this.nodes = {};
      if (this.source()) this.addAll();
      this.context.observe(this.node_data.source, this.rebuild);
      this.context.observe(this.node_data.source, 'add', this.add);
      this.context.observe(this.node_data.source, 'remove', this.remove);
    }

    ForBlock.prototype.add = function(value) {
      var hash, key, new_context, new_node_data, node, _i, _len, _ref, _results,
        _this = this;
      this.nodes[value] = [];
      new_context = new WingmanObject;
      if (this.context.createChildView) {
        new_context.createChildView = function(name) {
          return _this.context.createChildView.call(_this.context, name);
        };
      }
      key = Fleck.singularize(this.node_data.source.split('.').pop());
      hash = {};
      hash[key] = value;
      new_context.set(hash);
      _ref = this.node_data.children;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        new_node_data = _ref[_i];
        node = NodeFactory.create(new_node_data, this.scope, new_context);
        _results.push(this.nodes[value].push(node));
      }
      return _results;
    };

    ForBlock.prototype.remove = function(value) {
      var node;
      while (this.nodes[value].length) {
        node = this.nodes[value].pop();
        node.remove();
      }
      return delete this.nodes[value];
    };

    ForBlock.prototype.source = function() {
      return this.context.get(this.node_data.source);
    };

    ForBlock.prototype.addAll = function() {
      var _this = this;
      return this.source().forEach(function(value) {
        return _this.add(value);
      });
    };

    ForBlock.prototype.removeAll = function() {
      var element, value, _ref, _results;
      _ref = this.nodes;
      _results = [];
      for (value in _ref) {
        element = _ref[value];
        _results.push(this.remove(value));
      }
      return _results;
    };

    ForBlock.prototype.rebuild = function() {
      this.removeAll();
      if (this.source()) return this.addAll();
    };

    return ForBlock;

  })();

}).call(this);
}, "wingman-client/template/parser": function(exports, require, module) {(function() {
  var StringScanner, Value, self_closing_tags;

  StringScanner = require("strscan").StringScanner;

  Value = require("./parser/value");

  self_closing_tags = ['input', 'img', 'br', 'hr'];

  module.exports = (function() {

    _Class.parse = function(source) {
      var parser;
      parser = new this(source);
      parser.execute();
      return parser.tree;
    };

    _Class.trimSource = function(source) {
      var line, lines, _i, _len, _ref;
      lines = [];
      _ref = source.split("\n");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        lines.push(line.replace(/^ +/, ''));
      }
      return lines.join('').replace(/[\n\r\t]/g, '');
    };

    function _Class(source) {
      this.scanner = new StringScanner(this.constructor.trimSource(source));
      this.tree = {
        children: []
      };
      this.current_scope = this.tree;
    }

    _Class.prototype.execute = function() {
      var _results;
      _results = [];
      while (!this.done) {
        if (this.scanner.hasTerminated()) {
          _results.push(this.done = true);
        } else {
          _results.push(this.scan());
        }
      }
      return _results;
    };

    _Class.prototype.scan = function() {
      return this.scanForEndTag() || this.scanForStartTag() || this.scanForIfToken() || this.scanForElseToken() || this.scanForViewToken() || this.scanForForToken() || this.scanForEndToken() || this.scanForText();
    };

    _Class.prototype.scanForEndTag = function() {
      var result;
      result = this.scanner.scan(/<\/(.*?)>/);
      if (result) this.current_scope = this.current_scope.parent;
      return result;
    };

    _Class.prototype.scanForStartTag = function() {
      var attributes, new_node, result;
      result = this.scanner.scan(/<([a-zA-Z0-9]+) *(.*?)>/);
      if (result) {
        new_node = {
          tag: this.scanner.getCapture(0),
          children: [],
          parent: this.current_scope,
          type: 'element'
        };
        if (this.scanner.getCapture(1)) {
          attributes = this.parseAttributes(this.scanner.getCapture(1));
          this.addAttributes(new_node, attributes);
        }
        this.current_scope.children.push(new_node);
        if (self_closing_tags.indexOf(new_node.tag) === -1) {
          this.current_scope = new_node;
        }
      }
      return result;
    };

    _Class.prototype.scanForForToken = function() {
      var new_node, result;
      result = this.scanner.scan(/\{for (.*?)\}/);
      if (result) {
        new_node = {
          source: this.scanner.getCapture(0),
          children: [],
          parent: this.current_scope,
          type: 'for'
        };
        this.current_scope.children.push(new_node);
        this.current_scope = new_node;
      }
      return result;
    };

    _Class.prototype.scanForViewToken = function() {
      var new_node, result;
      result = this.scanner.scan(/\{view (.*?)\}/);
      if (result) {
        new_node = {
          name: this.scanner.getCapture(0),
          parent: this.current_scope,
          type: 'child_view'
        };
        this.current_scope.children.push(new_node);
      }
      return result;
    };

    _Class.prototype.scanForIfToken = function() {
      var new_node, result;
      result = this.scanner.scan(/\{if (.*?)\}/);
      if (result) {
        new_node = {
          source: this.scanner.getCapture(0),
          parent: this.current_scope,
          type: 'conditional',
          children: []
        };
        new_node.true_children = new_node.children;
        this.current_scope.children.push(new_node);
        this.current_scope = new_node;
      }
      return result;
    };

    _Class.prototype.scanForElseToken = function() {
      var result;
      result = this.scanner.scan(/\{else\}/);
      if (result) {
        this.current_scope.children = this.current_scope.false_children = [];
      }
      return result;
    };

    _Class.prototype.scanForEndToken = function() {
      var result;
      result = this.scanner.scan(/\{end\}/);
      if (result) {
        if (this.current_scope.type === 'conditional') {
          delete this.current_scope.children;
        }
        this.current_scope = this.current_scope.parent;
      }
      return result;
    };

    _Class.prototype.scanForText = function() {
      var result;
      result = this.scanner.scanUntil(/</);
      this.current_scope.value = new Value(result.substr(0, result.length - 1));
      this.scanner.head -= 1;
      return result;
    };

    _Class.prototype.parseAttributes = function(attributes_as_string) {
      var attributes;
      attributes = {};
      attributes_as_string.replace(new RegExp('([a-z]+)="(.*?)"', "g"), function($0, $1, $2) {
        return attributes[$1] = $2;
      });
      return attributes;
    };

    _Class.prototype.parseStyle = function(styles_as_string) {
      var re, split, style_as_string, styles, _i, _len, _ref;
      re = new RegExp(' ', 'g');
      styles = {};
      _ref = styles_as_string.replace(re, '').split(';');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        style_as_string = _ref[_i];
        split = style_as_string.split(':');
        styles[split[0]] = new Value(split[1]);
      }
      return styles;
    };

    _Class.prototype.parseClass = function(classes_as_string) {
      var classes, klass, _i, _len, _ref;
      classes = [];
      _ref = classes_as_string.split(' ');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        klass = _ref[_i];
        classes.push(new Value(klass));
      }
      return classes;
    };

    _Class.prototype.addAttributes = function(node, attributes) {
      var key, value, _results;
      if (attributes.style) {
        node.styles = this.parseStyle(attributes.style);
        delete attributes.style;
      }
      if (attributes["class"]) {
        node.classes = this.parseClass(attributes["class"]);
        delete attributes["class"];
      }
      if (Object.keys(attributes).length !== 0) {
        node.attributes = {};
        _results = [];
        for (key in attributes) {
          value = attributes[key];
          _results.push(node.attributes[key] = new Value(value));
        }
        return _results;
      }
    };

    return _Class;

  })();

}).call(this);
}, "wingman-client/template/parser/value": function(exports, require, module) {(function() {

  module.exports = (function() {

    function _Class(body) {
      var match;
      this.body = body;
      match = this.body.match(/^\{(.*?)\}$/);
      this.is_dynamic = !!match;
      if (this.is_dynamic) this.body = match[1];
    }

    _Class.prototype.get = function(context) {
      if (this.is_dynamic && context) {
        return context.get(this.body);
      } else {
        return this.body;
      }
    };

    return _Class;

  })();

}).call(this);
}, "wingman-client/view": function(exports, require, module) {(function() {
  var Elementary, Fleck, Wingman, WingmanObject,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Wingman = require('../wingman-client');

  WingmanObject = require('./shared/object');

  Elementary = require('./shared/elementary');

  Fleck = require('fleck');

  module.exports = (function(_super) {

    __extends(_Class, _super);

    _Class.include(Elementary);

    _Class.parseEvents = function(events_hash) {
      var key, trigger, _results;
      _results = [];
      for (key in events_hash) {
        trigger = events_hash[key];
        _results.push(this.parseEvent(key, trigger));
      }
      return _results;
    };

    _Class.parseEvent = function(key, trigger) {
      var type;
      type = key.split(' ')[0];
      return {
        selector: key.substring(type.length + 1),
        type: type,
        trigger: trigger
      };
    };

    function _Class(options) {
      _Class.__super__.constructor.call(this);
      if ((options != null ? options.parent : void 0) != null) {
        this.set({
          parent: options.parent
        });
      }
      if ((options != null ? options.app : void 0) != null) {
        this.set({
          app: options.app
        });
      }
      this.el = this.dom_element = (options != null ? options.el : void 0) || Wingman.document.createElement(this.tag || 'div');
      if (options != null ? options.render : void 0) this.render();
    }

    _Class.prototype.render = function() {
      var template, template_source;
      template_source = this.get('templateSource');
      if (template_source) {
        template = Wingman.Template.compile(template_source);
        template(this.el, this);
      }
      this.addClass(this.pathName());
      this.setupListeners();
      return typeof this.ready === "function" ? this.ready() : void 0;
    };

    _Class.prototype.createChildView = function(view_name) {
      var class_name, klass, view,
        _this = this;
      class_name = Fleck.camelize("" + view_name + "_view", true);
      klass = this.constructor[class_name];
      view = new klass({
        parent: this,
        app: this.get('app')
      });
      view.bind('descendantCreated', function(view) {
        return _this.trigger('descendantCreated', view);
      });
      this.trigger('descendantCreated', view);
      view.render();
      return view;
    };

    _Class.prototype.templateSource = function() {
      var name, template_source;
      name = this.get('templateName');
      template_source = this.constructor.template_sources[name];
      if (!template_source) throw new Error("Template '" + name + "' not found.");
      return template_source;
    };

    _Class.prototype.templateName = function() {
      return this.path();
    };

    _Class.prototype.setupListeners = function() {
      var _this = this;
      this.el.addEventListener('click', function(e) {
        if (_this.click) return _this.click(e);
      });
      if (this.events) return this.setupEvents();
    };

    _Class.prototype.setupEvents = function() {
      var event, _i, _len, _ref, _results;
      _ref = this.constructor.parseEvents(this.events);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        event = _ref[_i];
        _results.push(this.setupEvent(event));
      }
      return _results;
    };

    _Class.prototype.triggerWithCustomArguments = function(trigger) {
      var args, arguments_method_name, custom_arguments;
      args = [trigger];
      arguments_method_name = Fleck.camelize(trigger) + "Arguments";
      custom_arguments = typeof this[arguments_method_name] === "function" ? this[arguments_method_name]() : void 0;
      if (custom_arguments) args.push.apply(args, custom_arguments);
      return this.trigger.apply(this, args);
    };

    _Class.prototype.setupEvent = function(event) {
      var _this = this;
      return this.el.addEventListener(event.type, function(e) {
        var current, elm, match, _i, _len, _ref, _results;
        _ref = Array.prototype.slice.call(_this.el.querySelectorAll(event.selector), 0);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          elm = _ref[_i];
          current = e.target;
          while (current !== _this.el && !match) {
            match = elm === current;
            current = current.parentNode;
          }
          if (match) {
            _this.triggerWithCustomArguments(event.trigger);
            _results.push(e.preventDefault());
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
    };

    _Class.prototype.pathName = function() {
      return Fleck.underscore(this.constructor.name.replace(/([A-Z])/g, ' $1').substring(1).split(' ').slice(0, -1).join(''));
    };

    _Class.prototype.append = function(view) {
      return this.el.appendChild(view.el);
    };

    _Class.prototype.pathKeys = function() {
      var path_keys, _ref;
      if (this.isRoot()) return [];
      path_keys = [this.pathName()];
      if (((_ref = this.get('parent')) != null ? _ref.pathKeys : void 0) != null) {
        path_keys = this.get('parent').pathKeys().concat(path_keys);
      }
      return path_keys;
    };

    _Class.prototype.isRoot = function() {
      return this.get('parent') instanceof Wingman.Application;
    };

    _Class.prototype.path = function() {
      if (this.get('parent') instanceof Wingman.Application) {
        return 'root';
      } else {
        return this.pathKeys().join('.');
      }
    };

    return _Class;

  })(WingmanObject);

}).call(this);
}, "strscan": function(exports, require, module) {(function() {
  var StringScanner;
  ((typeof exports !== "undefined" && exports !== null) ? exports : this).StringScanner = (function() {
    StringScanner = function(source) {
      this.source = source.toString();
      this.reset();
      return this;
    };
    StringScanner.prototype.scan = function(regexp) {
      var matches;
      return (matches = regexp.exec(this.getRemainder())) && matches.index === 0 ? this.setState(matches, {
        head: this.head + matches[0].length,
        last: this.head
      }) : this.setState([]);
    };
    StringScanner.prototype.scanUntil = function(regexp) {
      var matches;
      if (matches = regexp.exec(this.getRemainder())) {
        this.setState(matches, {
          head: this.head + matches.index + matches[0].length,
          last: this.head
        });
        return this.source.slice(this.last, this.head);
      } else {
        return this.setState([]);
      }
    };
    StringScanner.prototype.scanChar = function() {
      return this.scan(/[\s\S]/);
    };
    StringScanner.prototype.skip = function(regexp) {
      if (this.scan(regexp)) {
        return this.match.length;
      }
    };
    StringScanner.prototype.skipUntil = function(regexp) {
      if (this.scanUntil(regexp)) {
        return this.head - this.last;
      }
    };
    StringScanner.prototype.check = function(regexp) {
      var matches;
      return (matches = regexp.exec(this.getRemainder())) && matches.index === 0 ? this.setState(matches) : this.setState([]);
    };
    StringScanner.prototype.checkUntil = function(regexp) {
      var matches;
      if (matches = regexp.exec(this.getRemainder())) {
        this.setState(matches);
        return this.source.slice(this.head, this.head + matches.index + matches[0].length);
      } else {
        return this.setState([]);
      }
    };
    StringScanner.prototype.peek = function(length) {
      return this.source.substr(this.head, (typeof length !== "undefined" && length !== null) ? length : 1);
    };
    StringScanner.prototype.getSource = function() {
      return this.source;
    };
    StringScanner.prototype.getRemainder = function() {
      return this.source.slice(this.head);
    };
    StringScanner.prototype.getPosition = function() {
      return this.head;
    };
    StringScanner.prototype.hasTerminated = function() {
      return this.head === this.source.length;
    };
    StringScanner.prototype.getPreMatch = function() {
      if (this.match) {
        return this.source.slice(0, this.head - this.match.length);
      }
    };
    StringScanner.prototype.getMatch = function() {
      return this.match;
    };
    StringScanner.prototype.getPostMatch = function() {
      if (this.match) {
        return this.source.slice(this.head);
      }
    };
    StringScanner.prototype.getCapture = function(index) {
      return this.captures[index];
    };
    StringScanner.prototype.reset = function() {
      return this.setState([], {
        head: 0,
        last: 0
      });
    };
    StringScanner.prototype.terminate = function() {
      return this.setState([], {
        head: this.source.length,
        last: this.head
      });
    };
    StringScanner.prototype.concat = function(string) {
      return this.source += string;
    };
    StringScanner.prototype.unscan = function() {
      if (this.match) {
        return this.setState([], {
          head: this.last,
          last: 0
        });
      } else {
        throw "nothing to unscan";
      }
    };
    StringScanner.prototype.setState = function(matches, values) {
      var _a, _b;
      this.head = (typeof (_a = ((typeof values === "undefined" || values === null) ? undefined : values.head)) !== "undefined" && _a !== null) ? _a : this.head;
      this.last = (typeof (_b = ((typeof values === "undefined" || values === null) ? undefined : values.last)) !== "undefined" && _b !== null) ? _b : this.last;
      this.captures = matches.slice(1);
      return (this.match = matches[0]);
    };
    return StringScanner;
  })();
})();
}, "fleck": function(exports, require, module) {/*!
  * fleck - functional style string inflections
  * https://github.com/trek/fleck
  * copyright Trek Glowacki
  * MIT License
  */
  
!function (name, definition) {
  if (typeof module != 'undefined') module.exports = definition()
  else if (typeof define == 'function' && typeof define.amd == 'object') define(definition)
  else this[name] = definition()
}('fleck', function () {
  
  var lib = {
    // plural rules, singular rules, and starting uncountables
    // from http://code.google.com/p/inflection-js/
    // with corrections for ordering and spelling
    pluralRules: [
      [new RegExp('(m)an$', 'gi'),                 '$1en'],
      [new RegExp('(pe)rson$', 'gi'),              '$1ople'],
      [new RegExp('(child)$', 'gi'),               '$1ren'],
      [new RegExp('^(ox)$', 'gi'),                 '$1en'],
      [new RegExp('(ax|test)is$', 'gi'),           '$1es'],
      [new RegExp('(octop|vir)us$', 'gi'),         '$1i'],
      [new RegExp('(alias|status)$', 'gi'),        '$1es'],
      [new RegExp('(bu)s$', 'gi'),                 '$1ses'],
      [new RegExp('(buffal|tomat|potat)o$', 'gi'), '$1oes'],
      [new RegExp('([ti])um$', 'gi'),              '$1a'],
      [new RegExp('sis$', 'gi'),                   'ses'],
      [new RegExp('(?:([^f])fe|([lr])f)$', 'gi'),  '$1$2ves'],
      [new RegExp('(hive)$', 'gi'),                '$1s'],
      [new RegExp('([^aeiouy]|qu)y$', 'gi'),       '$1ies'],
      [new RegExp('(matr|vert|ind)ix|ex$', 'gi'),  '$1ices'],
      [new RegExp('(x|ch|ss|sh)$', 'gi'),          '$1es'],
      [new RegExp('([m|l])ouse$', 'gi'),           '$1ice'],
      [new RegExp('(quiz)$', 'gi'),                '$1zes'],
      [new RegExp('s$', 'gi'),                     's'],
      [new RegExp('$', 'gi'),                      's']
    ],
    singularRules: [
      [new RegExp('(m)en$', 'gi'),                                                       '$1an'],
      [new RegExp('(pe)ople$', 'gi'),                                                    '$1rson'],
      [new RegExp('(child)ren$', 'gi'),                                                  '$1'],
      [new RegExp('([ti])a$', 'gi'),                                                     '$1um'],
      [new RegExp('((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$','gi'), '$1$2sis'],
      [new RegExp('(hive)s$', 'gi'),                                                     '$1'],
      [new RegExp('(tive)s$', 'gi'),                                                     '$1'],
      [new RegExp('(curve)s$', 'gi'),                                                    '$1'],
      [new RegExp('([lr])ves$', 'gi'),                                                   '$1f'],
      [new RegExp('([^fo])ves$', 'gi'),                                                  '$1fe'],
      [new RegExp('([^aeiouy]|qu)ies$', 'gi'),                                           '$1y'],
      [new RegExp('(s)eries$', 'gi'),                                                    '$1eries'],
      [new RegExp('(m)ovies$', 'gi'),                                                    '$1ovie'],
      [new RegExp('(x|ch|ss|sh)es$', 'gi'),                                              '$1'],
      [new RegExp('([m|l])ice$', 'gi'),                                                  '$1ouse'],
      [new RegExp('(bus)es$', 'gi'),                                                     '$1'],
      [new RegExp('(o)es$', 'gi'),                                                       '$1'],
      [new RegExp('(shoe)s$', 'gi'),                                                     '$1'],
      [new RegExp('(cris|ax|test)es$', 'gi'),                                            '$1is'],
      [new RegExp('(octop|vir)i$', 'gi'),                                                '$1us'],
      [new RegExp('(alias|status)es$', 'gi'),                                            '$1'],
      [new RegExp('^(ox)en', 'gi'),                                                      '$1'],
      [new RegExp('(vert|ind)ices$', 'gi'),                                              '$1ex'],
      [new RegExp('(matr)ices$', 'gi'),                                                  '$1ix'],
      [new RegExp('(quiz)zes$', 'gi'),                                                   '$1'],
      [new RegExp('s$', 'gi'),                                                           '']
    ],
    uncountableWords: {
      'equipment': true,
      'information': true,
      'rice': true,
      'money': true,
      'species': true,
      'series':true,
      'fish':true,
      'sheep':true,
      'moose':true,
      'deer':true, 
      'news':true
    },
    // Chain multiple inflections into a signle call
    // Examples:
    //   lib.inflect('     posts', 'strip', 'singularize', 'capitalize') == 'Post'
    inflect: function(str){
      for (var i = 1, l = arguments.length; i < l; i++) {
        str = lib[arguments[i]](str);
      };

      return str;
    },
    // Uppercases the first letter and lowercases all other letters
    // Examples:
    //   lib.capitalize("message_properties") == "Message_properties"
    //   lib.capitalize("message properties") == "Message properties"
    capitalize: function(str) {
      return str.charAt(0).toUpperCase() + str.substring(1).toLowerCase();
    },
    // lib.camelize("message_properties") == "messageProperties"
    // lib.camelize('-moz-border-radius') == 'mozBorderRadius'
    // lib.camelize("message_properties", true) == "MessageProperties"
    camelize: function(str, upper){
      if (upper) { return lib.upperCamelize(str) };
      return str.replace(/[-_]+(.)?/g, function(match, chr) {
        return chr ? chr.toUpperCase() : '';
      });
    },
    // lib.upperCamelize("message_properties") == "MessageProperties"
    upperCamelize: function(str){
      return lib.camelize(lib.capitalize(str));
    },
    // Replaces all spaces or underscores with dashes
    // Examples:
    //   lib.dasherize("message_properties") == "message-properties"
    //   lib.dasherize("Message properties") == "Message-properties"
    dasherize: function(str){
      return str.replace(/\s|_/g, '-');
    },
    // turns number or string formatted number into ordinalize version
    // Examples:
    //   lib.ordinalize(4) == "4th"
    //   lib.ordinalize("13") == "13th"
    //   lib.ordinalize("122") == "122nd"
    ordinalize: function(str){
      var isTeen, r, n;
      n = parseInt(str, 10) % 100;
      isTeen = { 11: true, 12: true, 13: true}[n];
      if(isTeen) {return str + 'th'};
      n = parseInt(str, 10) % 10
      switch(n) {
      case 1:
        r = str + 'st';
        break;
      case 2:
        r = str + 'nd';
        break;
      case 3:
        r = str + 'rd';
        break;
      default:
        r = str + 'th';
      }
      return r;
    },
    pluralize: function(str){
      var uncountable = lib.uncountableWords[str.toLowerCase()];
      if (uncountable) {
        return str;
      };
      var rules = lib.pluralRules;
      for(var i = 0, l = rules.length; i < l; i++){
        if (str.match(rules[i][0])) {
          str = str.replace(rules[i][0], rules[i][1]);
          break;
        };
      }

      return str;
    },
    singularize: function(str){
      var uncountable = lib.uncountableWords[str.toLowerCase()];
      if (uncountable) {
        return str;
      };
      var rules = lib.singularRules;
      for(var i = 0, l = rules.length; i < l; i++){
        if (str.match(rules[i][0])) {
          str = str.replace(rules[i][0], rules[i][1]);
          break;
        };
      }

      return str;
    },
    // Removes leading and trailing whitespace
    // Examples:
    //    lib.strip("    hello world!    ") == "hello world!"
    strip: function(str){
      // implementation from Prototype.js
      return str.replace(/^\s+/, '').replace(/\s+$/, '');
    },
    // Converts a camelized string into a series of words separated by an
    // underscore (`_`).
    // Examples
    //   lib.underscore('borderBottomWidth') == "border_bottom_width"
    //   lib.underscore('border-bottom-width') == "border_bottom_width"
    //   lib.underscore('Foo::Bar') == "foo_bar"
    underscore: function(str){
      // implementation from Prototype.js
      return str.replace(/::/g, '/')
                .replace(/([A-Z]+)([A-Z][a-z])/g, '$1_$2')
                .replace(/([a-z\d])([A-Z])/g, '$1_$2')
                .replace(/-/g, '_')
                .toLowerCase();
    },
    
    // add an uncountable word
    // fleck.uncountable('ninja', 'tsumani');
    uncountable: function(){
      for(var i=0,l=arguments.length; i<l; i++){
        lib.uncountableWords[arguments[i]] = true;
      }
      return lib;
    }
  };
  
  return lib;
  
});
}});

  window.Wingman = require('wingman-client');
})(window);