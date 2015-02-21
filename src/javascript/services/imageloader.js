;(function(window) {
  'use strict';

  var angular = window.angular;
  var localStorage = window.localStorage;

  angular
    .module('tuchong-daily')
    .service('imageLoader', [
      '$ionicLoading',
      '$timeout',
      imageLoader
    ]);

  function imageLoader($ionicLoading, $timeout) {
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
        if (!scope.slidesReady)
          scope.slidesReady = true;

        return $ionicLoading.hide();
      }

      if (!scope.collections && !scope.images) {
        loadError();
        $timeout($ionicLoading.hide, 400);

        return;
      }

      $ionicLoading.show(
        template: '<i class="icon ion-loading-c"></i> 图片加载中...'
      );

      var image = type === 'home' ?
        scope.collections[index].images[0].uri :
        scope.images[index].uri;

      loadImage(image, loadDone, loadError);

      function loadDone() {
        scope.backgrounds[index] = image;
        scope.$apply();

        if (!scope.slidesReady)
          scope.slidesReady = true;

        // Update the whole cache
        var cacheKey = type === 'home' ? type : id;
        self.cache[cacheKey] = scope.backgrounds;

        $ionicLoading.hide();
      }

      function loadError() {
        $ionicLoading.show(
          template: '图片加载失败，请稍后再试试...'
        );
      }
    }

    function loadImage(uri, callback, onerror) {
      ImageLoader.createImage(
        uri + '.jpg', 
        function(err, img) {
        img.onload = callback;
        img.onerror = onerror;
        img = null;
      });
    }
  }

})(this);
