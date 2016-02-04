// Events system from the Backbone project.
// https://github.com/jashkenas/backbone

// Backbone source license is as follows:

/*
Copyright (c) 2010-2016 Jeremy Ashkenas, DocumentCloud

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

var _ = {};
_.uniqueId = require('lodash/utility/uniqueId');
_.keys = require('lodash/object/keys');
_.isEmpty = require('lodash/lang/isEmpty');
_.bind = require('lodash/function/bind');
_.once = require('lodash/function/once');

var Events = {};

var array = [];
var slice = array.slice;

// Regular expression used to split event strings.
var eventSplitter = /\s+/;

// Iterates over the standard `event, callback` (as well as the fancy multiple
// space-separated events `"change blur", callback` and jQuery-style event
// maps `{event: callback}`), reducing them by manipulating `events`.
// Passes a normalized (single event name and callback), as well as the `context`
// and `ctx` arguments to `iteratee`.
var eventsApi = function(iteratee, memo, name, callback, context, ctx) {
  var i = 0, names, length;
  if (name && typeof name === 'object') {
    // Handle event maps.
    for (names = _.keys(name), length = names.length; i < length; i++) {
      memo = iteratee(memo, names[i], name[names[i]], context, ctx);
    }
  } else if (name && eventSplitter.test(name)) {
    // Handle space separated event names.
    for (names = name.split(eventSplitter), length = names.length; i < length; i++) {
      memo = iteratee(memo, names[i], callback, context, ctx);
    }
  } else {
    memo = iteratee(memo, name, callback, context, ctx);
  }
  return memo;
};

// Bind an event to a `callback` function. Passing `"all"` will bind
// the callback to all events fired.
Events.on = function(name, callback, context) {
  this._events = eventsApi(onApi, this._events || {}, name, callback, context, this);
  return this;
};

// Inversion-of-control versions of `on`. Tell *this* object to listen to
// an event in another object... keeping track of what it's listening to.
Events.listenTo =  function(obj, name, callback) {
  if (!obj) return this;
  var id = obj._listenId || (obj._listenId = _.uniqueId('l'));
  var listeningTo = this._listeningTo || (this._listeningTo = {});
  var listening = listeningTo[id];

  // This object is not listening to any other events on `obj` yet.
  // Setup the necessary references to track the listening callbacks.
  if (!listening) {
    listening = listeningTo[id] = {obj: obj, events: {}};
    id = this._listenId || (this._listenId = _.uniqueId('l'));
    var listeners = obj._listeners || (obj._listeners = {});
    listeners[id] = this;
  }

  // Bind callbacks on obj, and keep track of them on listening.
  obj.on(name, callback, this);
  listening.events = eventsApi(onApi, listening.events, name, callback);
  return this;
};

// The reducing API that adds a callback to the `events` object.
var onApi = function(events, name, callback, context, ctx) {
  if (callback) {
    var handlers = events[name] || (events[name] = []);
    handlers.push({callback: callback, context: context, ctx: context || ctx});
  }
  return events;
};

// Remove one or many callbacks. If `context` is null, removes all
// callbacks with that function. If `callback` is null, removes all
// callbacks for the event. If `name` is null, removes all bound
// callbacks for all events.
Events.off =  function(name, callback, context) {
  if (!this._events) return this;
  this._events = eventsApi(offApi, this._events, name, callback, context);

  var listeners = this._listeners;
  if (listeners) {
    // Listeners always bind themselves as the context, so if `context`
    // is passed, narrow down the search to just that listener.
    var ids = context != null ? [context._listenId] : _.keys(listeners);

    for (var i = 0, length = ids.length; i < length; i++) {
      var listener = listeners[ids[i]];

      // Bail out if listener isn't listening.
      if (!listener) break;

      // Tell each listener to stop, without infinitely calling `#off`.
      internalStopListening(listener, this, name, callback);
    }
    if (_.isEmpty(listeners)) this._listeners = void 0;
  }
  return this;
};

// Tell this object to stop listening to either specific events ... or
// to every object it's currently listening to.
Events.stopListening =  function(obj, name, callback) {
  // Use an internal stopListening, telling it to call off on `obj`.
  if (this._listeningTo) internalStopListening(this, obj, name, callback, true);
  return this;
};

// The reducing API that removes a callback from the `events` object.
var offApi = function(events, name, callback, context) {
  // Remove all callbacks for all events.
  if (!events || !name && !context && !callback) return;

  var names = name ? [name] : _.keys(events);
  for (var i = 0, length = names.length; i < length; i++) {
    name = names[i];
    var handlers = events[name];

    // Bail out if there are no events stored.
    if (!handlers) break;

    // Find any remaining events.
    var remaining = [];
    if (callback || context) {
      for (var j = 0, k = handlers.length; j < k; j++) {
        var handler = handlers[j];
        if (
          callback && callback !== handler.callback &&
            callback !== handler.callback._callback ||
              context && context !== handler.context
        ) {
          remaining.push(handler);
        }
      }
    }

    // Replace events if there are any remaining.  Otherwise, clean up.
    if (remaining.length) {
      events[name] = remaining;
    } else {
      delete events[name];
    }
  }
  if (!_.isEmpty(events)) return events;
};

var internalStopListening = function(listener, obj, name, callback, offEvents) {
  var listeningTo = listener._listeningTo;
  var ids = obj ? [obj._listenId] : _.keys(listeningTo);
  for (var i = 0, length = ids.length; i < length; i++) {
    var id = ids[i];
    var listening = listeningTo[id];

    // If listening doesn't exist, this object is not currently
    // listening to obj. Break out early.
    if (!listening) break;
    obj = listening.obj;
    if (offEvents) obj._events = eventsApi(offApi, obj._events, name, callback, listener);

    // Events will only ever be falsey if all the event callbacks
    // are removed. If so, stop delete the listening.
    var events = eventsApi(offApi, listening.events, name, callback);
    if (!events) {
      delete listeningTo[id];
      delete listening.obj._listeners[listener._listenId];
    }
  }
  if (_.isEmpty(listeningTo)) listener._listeningTo = void 0;
};

// Bind an event to only be triggered a single time. After the first time
// the callback is invoked, it will be removed.
Events.once =  function(name, callback, context) {
  // Map the event into a `{event: once}` object.
  var events = onceMap(name, callback, _.bind(this.off, this));
  return this.on(events, void 0, context);
};

// Inversion-of-control versions of `once`.
Events.listenToOnce =  function(obj, name, callback) {
  // Map the event into a `{event: once}` object.
  var events = onceMap(name, callback, _.bind(this.stopListening, this, obj));
  return this.listenTo(obj, events);
};

// Reduces the event callbacks into a map of `{event: onceWrapper}`.
// `offer` unbinds the `onceWrapper` after it as been called.
var onceMap = function(name, callback, offer) {
  return eventsApi(function(map, name, callback, offer) {
    if (callback) {
      var once = map[name] = _.once(function() {
        offer(name, once);
        callback.apply(this, arguments);
      });
      once._callback = callback;
    }
    return map;
  }, {}, name, callback, offer);
};

// Trigger one or many events, firing all bound callbacks. Callbacks are
// passed the same arguments as `trigger` is, apart from the event name
// (unless you're listening on `"all"`, which will cause your callback to
// receive the true name of the event as the first argument).
Events.trigger =  function(name) {
  if (!this._events) return this;
  var args = slice.call(arguments, 1);

  // Pass `triggerSentinel` as "callback" param. If `name` is an object,
  // it `triggerApi` will be passed the property's value instead.
  eventsApi(triggerApi, this, name, triggerSentinel, args);
  return this;
};

// A known sentinel to detect triggering with a `{event: value}` object.
var triggerSentinel = {};

// Handles triggering the appropriate event callbacks.
var triggerApi = function(obj, name, sentinel, args) {
  if (obj._events) {
    // If `sentinel` is not the trigger sentinel, trigger was called
    // with a `{event: value}` object, and it is `value`.
    if (sentinel !== triggerSentinel) args = [sentinel].concat(args);

    var events = obj._events[name];
    var allEvents = obj._events.all;
    if (events) triggerEvents(events, args);
    if (allEvents) triggerEvents(allEvents, [name].concat(args));
  }
  return obj;
};

// A difficult-to-believe, but optimized internal dispatch function for
// triggering events. Tries to keep the usual cases speedy (most internal
// Backbone events have 3 arguments).
var triggerEvents = function(events, args) {
  var ev, i = -1, l = events.length, a1 = args[0], a2 = args[1], a3 = args[2];
  switch (args.length) {
    case 0: while (++i < l) (ev = events[i]).callback.call(ev.ctx); return;
    case 1: while (++i < l) (ev = events[i]).callback.call(ev.ctx, a1); return;
    case 2: while (++i < l) (ev = events[i]).callback.call(ev.ctx, a1, a2); return;
    case 3: while (++i < l) (ev = events[i]).callback.call(ev.ctx, a1, a2, a3); return;
    default: while (++i < l) (ev = events[i]).callback.apply(ev.ctx, args); return;
  }
};

// Aliases for backwards compatibility.
Events.bind   = Events.on;
Events.unbind = Events.off;

module.exports = Events
