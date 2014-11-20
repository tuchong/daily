;(function(angular, debug) {
  'use strict';
  var log;

  if (!angular)
    throw new Error('Angular.js is required');
  if (debug)
    log = debug('tuchong-daily:app');

  angular
    .module('tuchong-daily', [
      'ionic',
      'ngResource',
      'ngCordova'
    ])
    .constant('API_TOKEN', appConfigs.API_TOKEN)
    .constant('API_SERVER', appConfigs.API_SERVER)
    .constant('API_TOKEN_KEY', 'tuchong-daily-token')
    .constant('TC_SERVER', 'http://tuchong.com/api/')
    .config([
      '$httpProvider',
      '$stateProvider', 
      '$urlRouterProvider', 
      'API_TOKEN',
      'API_TOKEN_KEY',
      config
    ])
    .run([
      '$ionicPlatform',
      '$cordovaDevice', 
      '$cordovaPush', 
      init
    ]);

  function init($ionicPlatform, $cordovaDevice, $cordovaPush) {
    $ionicPlatform.ready(function() {
      var device = $cordovaDevice.getDevice();
      var uuid = $cordovaDevice.getUUID();

      // $cordovaPush.register({
      //   "badge":"true",
      //   "sound":"true",
      //   "alert":"true"
      // }).then(function(result) {
      //   alert(result);
      //   alert(JSON.stringify(result));
      //   alert('push service signup success!!');
      // }, function(err){
      //   alert('push service signup error ' + err);
      // });
      // Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
      // for form inputs)
      if (window.cordova && window.cordova.plugins.Keyboard)
        cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
      // org.apache.cordova.statusbar required
      if (window.StatusBar)
        StatusBar.styleDefault();
    });
  }

  function config($httpProvider, $stateProvider, $urlRouterProvider, API_TOKEN, API_TOKEN_KEY) {
    // Use X-Domain to request cross domain
    $httpProvider.defaults.useXDomain = true;
    delete $httpProvider.defaults.headers.common['X-Requested-With'];
    $httpProvider.defaults.headers.common[API_TOKEN_KEY || 'tuchong-daily-token'] = API_TOKEN;

    // States Routers
    $stateProvider
      .state('home', {
        url: '/',
        templateUrl: 'templates/home.html',
        controller: 'home'
      })
      .state('collection', {
        url: '/collection/:id',
        templateUrl: 'templates/collection.html',
        controller: 'collection'
      })
      .state('collection-single', {
        url: '/images?uri',
        templateUrl: 'templates/single.html',
        controller: 'collection-single'
      })
    
    // 404 Router
    $urlRouterProvider.otherwise('/');
  }

})(window.angular, window.debug);
