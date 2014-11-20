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
      imageLoader
    ]);

  function imageLoader(UI) {
    var self = this;
    this.load = loadBackground;
    this.cache = {};
    this.cache.collection = {};

    function loadBackground(index, scope, type, id) {
      if (!index) return;

      index = index - 1;

      if (scope.backgrounds[index])
        return UI.loading.hide();

      UI.loading.show('<i class="icon ion-loading-c"></i> 图片加载中...');

      var image = type === 'home' ? 
        scope.collections[index].images[0].uri :
        scope.images[index].uri ;

      loadImage(image, loadDone, loadError);

      function loadDone() {
        if (log)
          log('Image loaded: %s:', image);

        scope.backgrounds[index] = image;
        scope.$apply();

        // Update the whole cache
        if (type === 'home')
          self.cache[type] = scope.backgrounds;
        if (type === 'collection')
          self.cache.collection[id] = scope.backgrounds;

        UI.loading.hide();
      }

      function loadError() {
        if (log)
          log('Image load error!');

        UI.loading.show('图片加载失败，请稍后再试试...');
      }
    }

    function loadImage(uri, callback, onerror) {
      var img = new Image();
      img.onload = callback;
      img.onerror = onerror;
      img.src = uri + '.jpg';
    }
  }

})(window.angular, window.debug);