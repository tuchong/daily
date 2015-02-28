;(function(window) {
  'use strict';

  var angular = window.angular;

  angular
    .module('tuchong-daily')
    .service('Store', [
      '$resource',
      'API_SERVER',
      'API_TOKEN',
      'TC_SERVER',
      store
    ]);

  function store($resource, API_SERVER, API_TOKEN, TC_SERVER) {
    var self = this;
    self.tuchong = {};
    var apiMap = {
      'hot': '/daily',
      'post': '/post'
    };
    var tuchongApiMap = {
      'post': 'post/get-post-and-images'
    };
    var extraMethods = {
      'post': {
        method: 'POST'
      },
      'update': {
        method: 'PUT'
      },
      'put': {
        method: 'PUT'
      }
    };
    self.cache = {};

    // Create `$resource` instance
    angular.forEach(apiMap, function(endpoint, key) {
      self[key] = $resource(
        API_SERVER + endpoint, null, extraMethods
      );
    });
    angular.forEach(tuchongApiMap, function(endpoint, key) {
      self.tuchong[key] = $resource(
        TC_SERVER + endpoint, null, extraMethods
      );
    });

    self.save = function(k, value) {
      self.cache[k] = value;
    };

    self.findById = function(id) {
      var result = null;

      if (!id || !self.cache.collections)
        return result;

      angular.forEach(self.cache.collections, function(item) {
        if (item.postId === id)
          result = item;
      });

      return result;
    };
  }

})(this);