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
      'avoscloud',
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
      'avoscloudProvider', 
      'API_TOKEN',
      'API_TOKEN_KEY',
      config
    ])
    .run([
      '$ionicPlatform',
      '$cordovaDevice', 
      '$cordovaPush',
      '$timeout',
      'avoscloud',
      '$cordovaDialogs',
      init
    ]);

  function init($ionicPlatform, $cordovaDevice, $cordovaPush, $timeout, avoscloud, $cordovaDialogs) {
    $ionicPlatform.ready(function() {
      var device = $cordovaDevice.getDevice();
      if (log) log(device);

      authPushService(device, function(installation){
        if (log) log(installation);

        avoscloud
          .installations
          .post(installation, syncInstallationSuccess, syncError);

        // When sync device infomation success
        function syncInstallationSuccess(result) {
          if (log) log(result);
        }

        // Ignore the error for tmp.
        function syncError(err) {
          if (log) log(err);
        }
      });

      // org.apache.cordova.statusbar required
      if (window.StatusBar)
        StatusBar.styleDefault();
    });

    function authPushService(device, callback) {
      var options = {
        "badge":"true",
        "sound":"true",
        "alert":"true"
      };

      $cordovaPush
        .register(options)
        .then(function(token) {
        if (log)
          log('Push service signup success, token: %s', token);

        var installation = {};

        installation.deviceType = device.platform ? 
          device.platform.toLowerCase() : 
          'ios';

        if (installation.deviceType === 'ios')
          installation.deviceToken = token;

        if (installation.deviceType === 'android')
          installation.installationId = token;

        return callback(installation);
      }, pushSignupError);

      // Ignore the error for tmp.
      function pushSignupError(err) {
        if (log) log(err);

        $cordovaDialogs.alert(
          '(¬_¬)ﾉ 请手动在 设置 > 通知 启用推送', // message
          '获取推送权限失败...', // title,
          '知道了' // button
        )
      }
    }
  }

  function config($httpProvider, $stateProvider, $urlRouterProvider, avoscloudProvider, API_TOKEN, API_TOKEN_KEY) {
    // Configs push service
    avoscloudProvider.config(appConfigs.avoscloud);

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
