;(function(angular, debug) {
  'use strict';
  var log;

  if (!angular)
    throw new Error('Angular.js is required');
  if (debug)
    log = debug('tuchong-daily:SlideLoader');

  angular
    .module('tuchong-daily')
    .service('slideLoader', [
      slideLoader
    ]);

  function slideLoader() {
    var self = this;
    this.lazyload = lazyload;
    this.reslove = reslove;
    this.index = {};
    this.index.absolute = {};
    this.index.relative = {};
    this.defaultRange = 3;

    function lazyload(type, data, fresh) {
      var startPoint = fresh ? 0 : (this.index.absolute[type] || 0);
      return spliceRange(data, range(startPoint));
    }

    function update(type, index) {
      self.index.relative[type] = index;
    }

    function reslove() {

    }
  }

  function range(point) {
    if (!point)
      return [0, 1, 2];
    point = parseInt(point, 10);
    return [point - 1 , point, point + 1];
  }

  function spliceRange(arr, indexes) {
    if (log) log(indexes);

    var ret = [];
    for (var i = 0; i < indexes.length; i++) {
      (function(j){
        ret.push(arr[indexes[j]]);
      })(i);
    };
    return ret;
  }

})(window.angular, window.debug);
