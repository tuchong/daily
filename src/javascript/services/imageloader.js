;(function(window) {
  'use strict';

  var angular = window.angular;
  var ImageLoader = window.ImageLoader;
  var ismobile = window.navigator.userAgent.match(/(iPad)|(iPhone)|(iPod)|(android)|(webOS)/i);

  angular
    .module('tuchong-daily')
    .service('imageLoader', [
      '$ionicLoading',
      '$timeout',
      imageLoader
    ]);

  function imageLoader($ionicLoading, $timeout) {
    this.load = load;

    function load(uri, callback, showloading) {
      if (showloading)
        $ionicLoading.show();

      var img = new BlobImage(ismobile ? uri : proxy(uri));
      img.element.onload = success;
      img.element.onerror = fail;

      function success() {
        $ionicLoading.hide();
        callback(img.blobURL);
        img = null;
      }

      function fail() {
        $ionicLoading.show({
          template: '图片加载失败，请稍后再试试...'
        });
        img = null;

        $timeout($ionicLoading.hide, 1000);
      }

      function proxy(realuri) {
        return realuri.replace(
          'http://photos.tuchong.com', 
          'http://localhost:8100/photos'
        );
      }
    }
  }
})(this);
