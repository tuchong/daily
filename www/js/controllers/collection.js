;(function(angular, debug, localStorage) {
  'use strict';
  var log;

  if (!angular)
    throw new Error('Angular.js is required');
  if (debug)
    log = debug('tuchong-daily:Controller:Collection');

  angular
    .module('tuchong-daily')
    .controller('collection', [
      '$scope',
      'Store',
      'UI',
      '$ionicSlideBoxDelegate',
      '$stateParams',
      '$state',
      'imageLoader',
      '$ionicSideMenuDelegate',
      'share',
      collection
    ])
    .controller('collection-single', [
      '$scope',
      '$stateParams',
      '$state',
      single
    ])

  function collection(scope, Store, UI, $ionicSlideBoxDelegate, $stateParams, $state, imageLoader, $ionicSideMenuDelegate, share) {
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
        if (log) log(result);
        collection = result;
        setup(result, true);
      }, function(err) {
        if (log) log(err);
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
      if (log) log('Switching to slide: [%s]', index);

      imageLoader.load(index, scope, 'collection', $stateParams.id);
      localStorage.lastSlideIndexCollection = index;

      if (log) log('Set lastSlideIndexCollection to %s', index);

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

      if (!scope.images || !scope.images[index])
        return UI.loading.show('<i class="icon ion-information-circled"></i> 啊喔，找不到大图了')

      // Find the image uri and go to single page
      $state.go('collection-single', {
        uri: scope.images[index].uri
      });
    }
  }

  function single(scope, $stateParams, $state) {
    if (!$stateParams.uri)
      return $state.go('home');

    scope.uri = $stateParams.uri;
  }

})(window.angular, window.debug, window.localStorage);
