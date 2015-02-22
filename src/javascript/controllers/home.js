;(function(window) {
  'use strict';

  var angular = window.angular;
  var localStorage = window.localStorage;

  angular
    .module('tuchong-daily')
    .controller('home', [
      '$scope',
      '$state',
      'Store',
      '$ionicLoading',
      '$timeout',
      '$rootScope',
      'imageLoader',
      '$cordovaDialogs',
      'share',
      home
    ]);

  function home(scope, $state, Store, $ionicLoading, $timeout, $rootScope, imageLoader, $cordovaDialogs, share) {
    scope.share = share.popup;

    var slides;
    var backgrounds = scope.backgrounds = [];
    // scope.backgrounds = imageLoader.loadCache('home');

    // Show loading message
    $ionicLoading.show({
      template: '<i class="icon ion-refreshing"></i> 努力加载中...'
    });

    // Read local cache from localStorage
    if (Store.cache.collections)
      return setup(Store.cache.collections);

    fetch();

    // Fetch fresh data from API server
    function fetch() {
      Store.hot.get({}, success, fail);

      function success(data){
        if (!data.collections) {
          $ionicLoading.show({
            template: '<i class="icon ion-close-circled"></i> 网络连接失败...请稍后再试'
          });
          return;
        }

        // Setup a few slides
        setup(data.collections, true);
        // Save all data to cache
        Store.save('collections', data.collections);
      }

      function fail(err) {
        $ionicLoading.show({
          template: '<i class="icon ion-close-circled"></i> 网络连接失败...请稍后再试'
        });
      }
    }

    function setup(data) {
      scope.collections = data;

      // Show befor init slides
      if (!scope.slidesReady)
        scope.slidesReady = true;

      // Hide loading
      $ionicLoading.hide();

      // Lazy loading the first slide's backgroud image
      loadImage(0);

      // Init the slides on next tick
      $timeout(function(){
        slides = new Swiper('.swiper-container-collection');

        // if children exist, render a sub vertical slides.
        new Swiper('.swiper-container-children', {
          direction: 'vertical'
        });

        // Load next page
        loadImage(1);
        loadImage(2);
      }, 10);
    }

    // Update slides async
    function loadImage(index) {
      if (backgrounds[index])
        return;

      imageLoader.load(
        scope.collections[index].images[0].uri + '.jpg',
        function(localImage) {
          scope.backgrounds[index] = localImage;
          scope.$apply();
        }
      );
    }
  }
})(this);
