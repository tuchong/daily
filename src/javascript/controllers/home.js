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
      home
    ]);

  function home(scope, Store, $ionicLoading, $timeout, imageLoader, share, $ionicModal) {
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
    function fetch() {
      Store.hot.get({}, success, fail);

      function success(data) {
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
      scope.collections = data;

      // Show befor init slides
      if (!scope.slidesReady)
        scope.slidesReady = true;

      // Hide loading
      $ionicLoading.hide();

      // Lazy loading the first slide's backgroud image
      if (scope.collections[0].images.length === 1) {
        loadImage(0);
      } else {
        loadChildImage(0, 0);
        $timeout(function() {
          setupChildrenSwiper(0);
        }, 10);
      }

      // Init the slides on next tick
      $timeout(function() {
        slides = new Swiper('.swiper-container-collection', {
          onSlideChangeStart: function() {
            var index = slides.activeIndex;
            loadImage(index);

            if (scope.collections[index].images.length > 1 && 'undefined' === typeof(childrenSlides[index])) {
              (function(ii) {
                setupChildrenSwiper(ii);

                loadChildImage(ii, 0);
              })(index);
            }
          }
        });
      }, 10);
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

    function loadChildImage(parentIndex, index) {
      if (Array.isArray(scope.childrens[parentIndex]) && scope.childrens[parentIndex][index])
        return;

      if (!Array.isArray(scope.childrens[parentIndex]))
        scope.childrens[parentIndex] = [];

      imageLoader.load(
        scope.collections[parentIndex].images[index].uri + '.jpg',
        function(localImage) {
          scope.childrens[parentIndex][index] = localImage;
          scope.$apply();
        }
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
  }
})(this);