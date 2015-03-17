;(function(window) {
  'use strict';

  var angular = window.angular;

  angular
    .module('tuchong-daily')
    .controller('home', [
      '$scope',
      'Store',
      '$ionicLoading',
      '$timeout',
      'imageLoader',
      'share',
      '$ionicModal',
      '$rootScope',
      '$cordovaDialogs',
      home
    ]);

  function home(scope, Store, $ionicLoading, $timeout, imageLoader, share, $ionicModal, $rootScope, $cordovaDialogs) {
    // When Push Received,
    // Render this notified post as first post.
    $rootScope.$on('pushNotificationReceived', pushNotificationReceived);

    scope.share = share.popup;
    scope.makeCssUri = makeCssUri;
    scope.openZoom = openZoom;
    scope.hideZoom = hideZoom;

    var slides = null;
    var childrenSlides = {};

    var backgrounds = scope.backgrounds = [];
    var childrens = scope.childrens = {};

    // Show loading
    $ionicLoading.show();

    // Read local cache from localStorage
    if (Store.cache.collections)
      return setup(Store.cache.collections);

    // Open a request
    fetch();

    // Fetch fresh data from API server
    function fetch(id) {
      var query = {};
      
      if (id)
        query.postId = id;

      Store[id ? 'post' : 'hot'].get(query, success, fail);

      function success(data) {
        if (id) {
          data.postId = id;
          return setup([data]);
        }

        if (!data.collections)
          return fail();

        // Setup a few slides
        setup(data.collections);

        // Save all data to cache
        Store.save('collections', data);
      }

      function fail(err) {
        $ionicLoading.show({
          template: '<i class="icon ion-ios-close-outline"></i> 网络连接失败...请稍后再试'
        });
        return false;
      }
    }

    // Setup slides view
    function setup(data) {
      var rendered = scope.collections && scope.collections.length > 0;

      scope.collections = rendered ?
        scope.collections.concat(data) : 
        data;

      // Show befor init slides
      if (!scope.slidesReady)
        scope.slidesReady = true;

      // Hide loading
      $ionicLoading.hide();

      var targetIndex = rendered && data.length === 1 ? 
        findIndex(data[0].postId, scope.collections) :
        0;

      // Load cover image
      loadCover(targetIndex, { 
        showLoading: true,
        setupChildrenSwiper: true,
        loadFirstChild: true
      });

      if (targetIndex === 0)
        loadCover(1);

      // Init the slides on next tick
      $timeout(function() {
        // When Push Received
        if (rendered && slides) {
          slides.updateSlidesSize();

          if (targetIndex !== 0)
            slides.slideTo(targetIndex);

          return;
        }

        slides = new Swiper('.swiper-container-collection', {
          onSlideChangeStart: function() {
            loadCover(slides.activeIndex, { 
              showLoading: true,
              setupChildrenSwiper: true,
              loadFirstChild: true
            });
          }
        });
      }, 10);
    }

    // Lazy loading the cover image of a slide
    function loadCover(index, opts) {
      if (!scope.collections[index])
        index -= 1;

      // If this collection have on one picture
      if (scope.collections[index].images.length === 1) 
        return;

      loadChildImage(index, 0, opts);

      // Load its first child if required
      if (opts && opts.loadFirstChild)
        loadChildImage(index, 1, opts);

      if (!opts || !opts.setupChildrenSwiper)
        return;

      if ('undefined' !== typeof(childrenSlides[index]))
        return;

      // Then setup its children slides
      $timeout(function() {
        setupChildrenSwiper(index);
      }, 10);
    }

    function findIndex(id, arr) {
      var target;
      angular.forEach(arr, function(item, index){
        if (item.postId === id)
          target = index;
      });
      return target;
    }

    function setupChildrenSwiper(index) {
      childrenSlides[index] = new Swiper('#children-' + index, {
        direction: 'vertical',
        onSlideChangeStart: function() {
          loadChildImage(index, childrenSlides[index].activeIndex);
        }
      });
    }

    // Update slides async
    function loadImage(index, opts) {
      if (backgrounds[index])
        return scope.$apply();

      imageLoader.load(
        scope.collections[index].images[0].uri + '.jpg',
        function(localImage) {
          backgrounds[index] = localImage;
          scope.$apply();
        },
        (opts && opts.showLoading) || true
      );
    }

    function loadChildImage(parentIndex, index, opts) {
      if (Array.isArray(childrens[parentIndex]) && childrens[parentIndex][index])
        return scope.$apply();

      if (!Array.isArray(childrens[parentIndex]))
        childrens[parentIndex] = [];

      if (!scope.collections[parentIndex])
        return;

      if (!scope.collections[parentIndex].images[index])
        return;

      imageLoader.load(
        scope.collections[parentIndex].images[index].uri + '.jpg',
        function(localImage) {
          childrens[parentIndex][index] = localImage;
          scope.$apply();
        },
        // ALWAYS show loading
        (opts && opts.showLoading) || true
      );
    }

    function openZoom(uri) {
      scope.zoomImage = uri;

      $ionicLoading.show({
        scope: scope,
        templateUrl: 'zoom-modal',
        hideOnStateChange: true
      });
    }

    function hideZoom() {
      $ionicLoading.hide();
    }

    function makeCssUri(str) {
      if (!str)
        return 'none';

      return 'url(' + str + ')';
    }

    function pushNotificationReceived(event, notification) {
      if (notification.collectionId) 
        return fetch(notification.collectionId);

      $cordovaDialogs.alert(
        notification.alert, // message
        '收到通知', // title,
        '知道了' // button
      )
    }
  }
})(this);