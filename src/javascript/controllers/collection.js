;(function(window) {
  'use strict';

  var angular = window.angular;
  var localStorage = window.localStorage;

  angular
    .module('tuchong-daily')
    .controller('collection', [
      '$scope',
      'Store',
      '$ionicLoading',
      '$ionicSlideBoxDelegate',
      '$stateParams',
      '$state',
      'imageLoader',
      '$ionicSideMenuDelegate',
      'share',
      '$timeout',
      '$cordovaDialogs',
      collection
    ])
    .controller('collection-single', [
      '$scope',
      '$stateParams',
      '$state',
      '$cordovaDialogs',
      single
    ])

  function collection(scope, Store, $ionicLoading, $ionicSlideBoxDelegate, $stateParams, $state, imageLoader, $ionicSideMenuDelegate, share, $timeout, $cordovaDialogs) {
    scope.toggle = toggle;
    scope.share = share.popup;
    scope.viewLarge = viewLarge;
    scope.updateSlides = updateSlides;
    scope.backgrounds = imageLoader.loadCache($stateParams.id);

    var collection = Store.findById($stateParams.id);

    if (!collection) {
      Store.post.get({
        postId: $stateParams.id
      }, function(result){
        collection = result;
        setup(result, true);
      }, function(err) {
        $state.go('home');
      });
      return;
    }

    setup(collection);

    function setup(collection, fresh) {
      var lastIndex = localStorage.lastSlideIndexCollection;
      var inValid = !lastIndex || parseInt(lastIndex) <= 3;

      scope.post = collection.post;
      
      // Lazy loading slides with a center point
      scope.images = fresh ? 
        angular.copy(collection.images).splice(0, 3) :
        angular.copy(collection.images).splice(0, inValid ? 3 : parseInt(lastIndex) + 1);

      imageLoader.load(0, scope, 'collection', $stateParams.id);

      $ionicSlideBoxDelegate.update();
    }

    function updateSlides(index) {
      console.log('Switching to slide: [%s]', index);

      imageLoader.load(index, scope, 'collection', $stateParams.id);
      localStorage.lastSlideIndexCollection = index;

      console.log('Set lastSlideIndexCollection to %s', index);

      if (!scope.images[index + 1] && collection.images[index + 1])
        scope.images.push(collection.images[index + 1]);

      $ionicSlideBoxDelegate.update();
    }

    function toggle(side) {
      var method = side === 'right' ? 
        'toggleRight': 'toggleLeft';
      $ionicSideMenuDelegate[method]();
    }

    function viewLarge() {
      var index = localStorage.lastSlideIndexCollection ?
        parseInt(localStorage.lastSlideIndexCollection) : 0;

      if (!scope.images || !scope.images[index]) {
        $ionicLoading.show({
          template: '<i class="icon ion-information-circled"></i> 啊喔，找不到大图了'
        });

        $timeout($ionicLoading.hide, 500);
        return;
      }

      // Find the image uri and go to single page
      $state.go('collection-single', {
        uri: scope.images[index].uri
      });
    }
  }

  function single(scope, $stateParams, $state, $cordovaDialogs) {
    if (!$stateParams.uri)
      return $state.go('home');

    scope.uri = $stateParams.uri;
    
    // When Push Received,
    // Jump to single collection page
    scope.$on('pushNotificationReceived', pushNotificationReceived);

    function pushNotificationReceived(event, notification) {
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
  }

})(this);
