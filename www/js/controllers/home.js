;(function(angular, debug, localStorage) {
  'use strict';
  var log;

  if (!angular)
    throw new Error('Angular.js is required');
  if (debug)
    log = debug('tuchong-daily:Controller:Home');

  angular
    .module('tuchong-daily')
    .controller('home', [
      '$scope',
      '$state',
      'Store',
      'UI',
      '$ionicSlideBoxDelegate',
      '$timeout',
      '$rootScope',
      'imageLoader',
      'slideLoader',
      '$cordovaDialogs',
      'share',
      home
    ]);

  function home(scope, $state, Store, UI, $ionicSlideBoxDelegate, $timeout, $rootScope, imageLoader, slideLoader, $cordovaDialogs, share) {
    scope.go = go;
    scope.share = share.popup;
    scope.updateSlides = updateSlides;
    scope.backgrounds = imageLoader.loadCache('home');

    // When Push Received,
    // Jump to single collection page
    scope.$on('pushNotificationReceived', pushNotificationReceived);

    // Listen to page changing event,
    // And jump to lastSlideIndex
    $rootScope.$on('$stateChangeSuccess', stateChangeSuccess);

    // Show loading message
    UI.loading.show('<i class="icon ion-refreshing"></i> 努力加载中...');

    // Read local cache from localStorage
    if (Store.cache.collections)
      return setup('home', Store.cache.collections);

    fetchFresh();

    function pushNotificationReceived(event, notification) {
      if (log) log(notification);

      if (notification.collectionId) {
        $state.go('collection', {
          id: notification.collectionId
        });
        return;
      }

      $cordovaDialogs.alert(
        notification.alert, // message
        '收到通知', // title,
        '知道了' // button
      )
    }

    // Fetch fresh data from API server
    function fetchFresh(callback) {
      Store.hot.get({}, success, fail);

      function success(data){
        if (!data.collections)
          return UI.loading.show('<i class="icon ion-close-circled"></i> 网络连接失败...请稍后再试');

        if (log) log(data.collections);

        // Setup a few slides
        setup('home', data.collections, true);
        // Save all data to cache
        Store.save('collections', data.collections);

        if (callback)
          callback();
      }

      function fail(err){
        UI.loading
          .show('<i class="icon ion-close-circled"></i> 网络连接失败...请稍后再试');

        if (callback)
          callback();
      }
    }

    // Init a slides with 3 slides,
    // If collection's pictures is above 3.
    function setup(type, collections, fresh) {
      // Lazy loading slides with a center point
      scope.collections = slideLoader.lazyload(type, collections, fresh);
      // Lazy loading the first slides' backgroud-image
      imageLoader.load(1, scope, 'home');
      
      $ionicSlideBoxDelegate.update();
    }

    // It shoud lazyloading in range 2 on both left side and right side
    function lazyLoadSlides(index) {
      var localCache = Store.cache.collections[index + 2];
      if (!scope.collections[index + 2] && localCache) {
        if (log) log('Lazyloading slides: %s', index + 2);
        scope.collections.push(localCache);
      }
    }

    // Update slides async
    function updateSlides(index) {
      if (log) log('Switching to slide: [%s]', index);

      // Loading this slide's backgroud-image
      imageLoader.load(index + 1, scope, 'home');

      // Update latest relative index
      slideLoader.update('home', index);

      // Lazyloading the slides after next slides.
      lazyLoadSlides(index);

      $ionicSlideBoxDelegate.update();
    }

    // Go to the target state
    function go(id, imagesLength) {
      var isValidCollection = imagesLength > 1;

      if (isValidCollection)
        return $state.go('collection', {id: id});

      UI.loading
        .show('<i class="icon ion-information-circled"></i> 这个相册只有一张图');

      $timeout(function(){
        UI.loading.hide();
      }, 500);
    }

    // When stats changes success, Go to the latest slide index
    function stateChangeSuccess(e, toState, toParams, fromState, fromParams) {
      if (log) log('%s => %s', fromState.name, toState.name);

      var isGoHome = toState.name === 'home';
      var isGoToCollection = fromState.name === 'collection-single' && toState.name === 'collection';

      if (!isGoHome && !isGoToCollection)
        return;

      var gotoIndex = isGoHome ?
        localStorage.lastSlideIndexHome :
        localStorage.lastSlideIndexCollection;

      gotoIndex = parseInt(gotoIndex);

      // Slide to last visited index.
      $timeout(function(){
        $ionicSlideBoxDelegate.slide(
          gotoIndex === 0 ? 0 : 1
        );
      }, 200);
    }
  }

})(window.angular, window.debug, window.localStorage);
