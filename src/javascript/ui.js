;(function(window) {
  'use strict';

  var angular = window.angular;

  angular
    .module('tuchong-daily')
    .service('UI', [
      '$ionicLoading',
      '$ionicPopup',
      ctrlerUI
    ]);

  function ctrlerUI($ionicLoading, $ionicPopup) {
    this.loading = {
      show: function(msg) {
        var otps = {};
        otps.template = msg;
        return $ionicLoading.show(otps);
      },
      hide: function() {
        return $ionicLoading.hide();
      }
    };
    this.alert = function(obj, callback) {
      $ionicPopup.alert(obj).then(callback);
    };
    this.confirm = function(obj, callback) {
      $ionicPopup.confirm(obj).then(callback);
    };
    this.popup = function(obj, callback) {
      $ionicPopup.show(obj).then(callback);
    };
  }

})(this);
