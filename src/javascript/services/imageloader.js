;(function(angular, debug) {
  'use strict';
  var log;

  if (!angular)
    throw new Error('Angular.js is required');
  if (debug)
    log = debug('tuchong-daily:ImageLoader');

  angular
    .module('tuchong-daily')
    .service('imageLoader', [
      'UI',
      '$timeout',
      imageLoader
    ]);

  function imageLoader(UI, $timeout) {
    var self = this;
    this.load = loadBackground;
    this.loadCache = loadCache;
    this.cache = {};

    function loadCache(type) {
      if (!self.cache[type])
        return [];
      return self.cache[type];
    }

    // 应该将逻辑统一化
    function loadBackground(index, scope, type, id) {
      if (index === undefined || index === null || isNaN(index)) 
        return;

      if (scope.backgrounds[index]) {
        if (log) 
          log('Reading image from cache');
        if (!scope.slidesReady) 
          scope.slidesReady = true;

        return UI.loading.hide();
      }

      if (!scope.collections && !scope.images) {
        UI.loading
          .show('图片加载失败，请稍后再试试..');
          
        $timeout(UI.loading.hide, 400);

        return;
      }

      UI.loading
        .show('<i class="icon ion-loading-c"></i> 图片加载中...');

      var image = type === 'home' ?
        scope.collections[index].images[0].uri :
        scope.images[index].uri ;

      loadImage(image, loadDone, loadError);

      function loadDone() {
        if (log) log('Image loaded: %s', image + '.jpg');

        scope.backgrounds[index] = image;
        scope.$apply();

        if (!scope.slidesReady)
          scope.slidesReady = true;

        // Update the whole cache
        var cacheKey = type === 'home' ? type : id;
        self.cache[cacheKey] = scope.backgrounds;

        UI.loading.hide();
      }

      function loadError() {
        UI.loading
          .show('图片加载失败，请稍后再试试...');
      }
    }

    function loadImage(uri, callback, onerror) {
      var img = new Image();
      img.onload = callback;
      img.onerror = onerror;
      img.src = uri + '.jpg';
      img = null;
    }
  }

})(window.angular, window.debug);
