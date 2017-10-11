'use strict';

var most = require('most');

var _from = function(instanceDict) {
  return function(iterableOrObservable) {
    return function() {
      return most.from(iterableOrObservable);
    };
  };
};

exports._fromIterable = _from;
exports._fromObservable = _from();

exports._of = function(a) {
  return function() {
    return most.of(a);
  };
};

exports._just = function(a) {
  return most.just(a);
};

exports._subscribe = function(observable) {
  return function(listeners) {
    return function() {
      return observable.subscribe(listeners);
    };
  };
};

exports._map = function(fn) {
  return function(observable) {
    return most.map(fn, observable);
  };
};

exports._apply = function(fn) {
  return function(observable) {
    return most.ap(fn, observable);
  };
};

exports._bind = function(ma) {
  return function(fn) {
    return most.chain(fn, ma);
  };
};

exports._append = function(a) {
  return function(b) {
    return most.concat(a, b);
  };
};

exports._mempty = most.empty();

exports._fromEvent = function(eventType) {
  return function(source) {
    return function(useCapture) {
      return most.fromEvent(eventType, source, useCapture);
    };
  };
};

exports._scan = function(fn) {
  return function(initial) {
    return function(stream) {
      return most.scan(function(a, b) { return fn(a)(b) }, initial, stream);
    };
  };
};

exports._take = function(n) {
  return function(stream) {
    return most.take(n, stream);
  };
};
