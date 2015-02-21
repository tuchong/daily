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
      '$ionicSlideBoxDelegate',
      '$timeout',
      '$rootScope',
      'imageLoader',
      '$cordovaDialogs',
      'share',
      home
    ]);

  function home(scope, $state, Store, $ionicLoading, $ionicSlideBoxDelegate, $timeout, $rootScope, imageLoader, $cordovaDialogs, share) {
    scope.go = go;
    scope.share = share.popup;
    scope.updateSlides = updateSlides;
    scope.backgrounds = imageLoader.loadCache('home');

    // Show loading message
    $ionicLoading.show(
      template: '<i class="icon ion-refreshing"></i> 努力加载中...'
    );

    // Read local cache from localStorage
    if (Store.cache.collections)
      return setup(Store.cache.collections);

    fetchFresh();

    // Fetch fresh data from API server
    function fetchFresh(callback) {
      Store.hot.get({}, success, fail);

      function success(data){
        if (!data.collections) {
          $ionicLoading.show(
            template: '<i class="icon ion-close-circled"></i> 网络连接失败...请稍后再试'
          );
          return;
        }

        // Setup a few slides
        setup(data.collections, true);
        // Save all data to cache
        Store.save('collections', data.collections);

        if (callback)
          callback();
      }

      function fail(err){
        $ionicLoading.show(
          template: '<i class="icon ion-close-circled"></i> 网络连接失败...请稍后再试'
        );

        if (callback)
          callback();
      }
    }

    // Init a slides with 3 slides,
    // If collection's pictures is above 3.
    function setup(collections, fresh) {
      var lastIndex = localStorage.lastSlideIndexHome;
      var inValid = !lastIndex || parseInt(lastIndex) <= 3;
      // Lazy loading slides with a center point
      scope.collections = fresh ? 
        angular.copy(collections).splice(0, 3) :
        angular.copy(collections).splice(0, inValid ? 3 : parseInt(lastIndex) + 1);

      // Lazy loading the first slide's backgroud-image
      imageLoader.load(0, scope, 'home');
      
      $ionicSlideBoxDelegate.update();
    }

    // Update slides async
    function updateSlides(index) {
      if (isNaN(index)) index = 0;

      console.log('Switching to slide: [%s]', index);

      // Loading this slide's backgroud-image
      imageLoader.load(index, scope, 'home');

      // Load the next slides
      if (!scope.collections[index + 1] && Store.cache.collections[index + 1])
        scope.collections.push(Store.cache.collections[index + 1]);

      // Update the latest index of home slides
      localStorage.lastSlideIndexHome = index;

      console.log('Set lastSlideIndexHome to %s', index);

      $ionicSlideBoxDelegate.update();
    }

    // Go to the target state
    function go(id, imagesLength) {
      var isValidCollection = imagesLength > 1;

      if (isValidCollection)
        return $state.go('collection', {id: id});

      $ionicLoading.show(
        template: '<i class="icon ion-information-circled"></i> 这个相册只有一张图'
      );

      $timeout($ionicLoading.hide, 400);
    }
  }

})(this);
