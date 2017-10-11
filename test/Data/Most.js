'use strict';

var EventEmitter = require('events');

exports.emitter = function() {
  return new EventEmitter();
};

exports["emit'"] = function(emitter) {
  return function(event) {
    return function(data) {
      return function() {
        return emitter.emit(event, data);
      };
    };
  };
};

exports.listenerCount = function(emitter) {
  return function(event) {
    return emitter.listenerCount(event);
  };
};

exports.stringifyEvent = function(event) {
  return JSON.stringify(event);
};
