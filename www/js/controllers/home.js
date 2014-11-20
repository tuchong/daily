;(function(angular, debug) {
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
      '$ionicActionSheet',
      '$ionicNavBarDelegate',
      '$timeout',
      '$rootScope',
      'imageLoader',
      home
    ]);

  function home(scope, $state, Store, UI, $ionicSlideBoxDelegate, $ionicActionSheet, $ionicNavBarDelegate, $timeout, $rootScope, imageLoader) {
    scope.go = go;
    scope.share = share;
    scope.refresh = refresh;
    scope.updateSlides = updateSlides;
    scope.backgrounds = imageLoader.cache && imageLoader.cache.home ? 
      imageLoader.cache.home :
      [];

    if (log)
      log(scope.backgrounds);

    $rootScope.$on('$stateChangeStart', stateChangeStart);
    $rootScope.$on('$stateChangeSuccess', stateChangeSuccess);

    // Show loading message
    UI.loading.show('<i class="icon ion-refreshing"></i> 努力加载中...');

    // Read local cache from localStroage
    if (Store.cache.collections) 
      return setup(Store.cache.collections);

    fetchFresh();

    // Fetch fresh data from API server    
    function fetchFresh(callback) {
      Store.hot.get({}, success, fail);

      function success(data){
        if (!data.collections)
          return UI.loading.show('<i class="icon ion-close-circled"></i> 网络连接失败...请稍后再试');  
        
        if (log)
          log(data.collections);

        setup(data.collections);
        Store.save('collections', data.collections);

        if (callback) 
          callback();
      }

      function fail(err){
        UI
          .loading
          .show('<i class="icon ion-close-circled"></i> 网络连接失败...请稍后再试');

        if (callback) 
          callback();
      }
    }

    // Init a slides with 3 slides,
    // If collection's pictures is above 3.
    function setup(collections) {
      if (collections.length > 3)
        scope.collections = [collections[0], collections[1], collections[2]];
      else
        scope.collections = scope.collections;

      imageLoader.load(1, scope, 'home');
      $ionicSlideBoxDelegate.update();
    }

    // Update slides async
    function updateSlides(index) {
      if (log)
        log('Switching to slide index: [%s]', index);

      imageLoader.load(index + 1, scope, 'home');
      scope.lastSlideIndex = index;

      if (!scope.collections[index + 2] && Store.cache.collections[index + 2])
        scope.collections.push(Store.cache.collections[index + 2]);
        
      $ionicSlideBoxDelegate.update();
    }

    // Go to the target state
    function go(id, imagesLength) {
      var isValidCollection = imagesLength > 1;

      if (isValidCollection)
        return $state.go('collection', {id: id});

      UI.loading.show('<i class="icon ion-information-circled"></i> 这个相册只有一张图');
      $timeout(function(){
        UI.loading.hide();
      }, 500);
    }

    // Refetch the page and fetching latest infomation
    function refresh() {
      fetchFresh(function(){
        scope.$broadcast('scroll.refreshComplete');
      });
    }

    // Show the sharing ActionSheet
    function share() {
       var hideSheet = $ionicActionSheet.show({
         buttons: [{ 
          text: '<i class="icon ion-forward"></i> 分享到微信' 
         },
         { 
          text: '<i class="icon ion-email"></i> 邮件发送' 
         }],
         titleText: '与朋友们分享好图...',
         cancelText: '算了',
         cancel: function() {
          
         },
         buttonClicked: function(index) {
           return true;
         }
       });
    }

    function stateChangeStart(event, toState, toParams, fromState, fromParams) {
      if (toState.name === 'collection') {
        UI.loading.show('<i class="icon ion-loading-c"></i> 正加载专辑...');
      }
    }

    function stateChangeSuccess(event, toState, toParams, fromState, fromParams) {
      // UI.loading.hide();
    }
  }

})(window.angular, window.debug);
