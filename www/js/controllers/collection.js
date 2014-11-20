;(function(angular, debug) {
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
      collection
    ])
    .controller('collection-single', [
      '$scope', 
      '$stateParams',
      '$state',
      single
    ])

  function collection(scope, Store, UI, $ionicSlideBoxDelegate, $stateParams, $state, imageLoader, $ionicSideMenuDelegate) {
    scope.viewLarge = viewLarge;
    scope.toggle = toggle;
    scope.updateSlides = updateSlides;

    var collection = Store.findById($stateParams.id);

    scope.backgrounds = imageLoader.cache && imageLoader.cache.collection && imageLoader.cache.collection[$stateParams.id] ? 
      imageLoader.cache.collection[$stateParams.id] :
      [];

    if (!collection) {
      Store.post.get({
        postId: $stateParams.id
      }, function(result){
        if (log) log(result);
        
        collection = result;
        setup(result);
      }, function(err) {
        if (log) log(err);
        $state.go('home');
      });
      return;
    }

    setup(collection);

    function setup(collection) {
      scope.post = collection.post;

      if (collection.images && collection.images.length > 3) 
        scope.images = [collection.images[0], collection.images[1], collection.images[2]];
      else 
        scope.images = collection.images;

      if (log)
        log(scope.post);

      imageLoader.load(1, scope, 'collection', $stateParams.id);
      $ionicSlideBoxDelegate.update();
    }

    function updateSlides(index) {
      if (log)
        log('Switching to slide index: [%s]', index);

      imageLoader.load(index + 1, scope, 'collection', $stateParams.id);
      scope.lastSlideIndex = index;

      if (!scope.images[index + 2] && collection.images[index + 2])
        scope.images.push(collection.images[index + 2]);

      $ionicSlideBoxDelegate.update();
    }
    
    function toggle(side) {
      var method = side === 'right' ? 'toggleRight': 'toggleLeft';
      $ionicSideMenuDelegate[method]();
    }

    function viewLarge() {
      var index = scope.lastSlideIndex || 0;
      // Find the image uri and go to single page
      $state.go('collection-single', {
        uri: scope.images[index].uri
      });
    }
  }

  function single(scope, $stateParams, $state) {
    if (log)
      log($stateParams)

    if (!$stateParams.uri)
      return $state.go('home');

    scope.uri = $stateParams.uri;
  }

})(window.angular, window.debug);