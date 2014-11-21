;(function(angular, debug) {
  'use strict';
  var log;

  if (!angular)
    throw new Error('Angular.js is required');
  if (debug)
    log = debug('tuchong-daily:Share');

  angular
    .module('tuchong-daily')
    .service('share', [
      '$ionicLoading',
      '$ionicActionSheet',
      ctrlerUI
    ]);

  function ctrlerUI($ionicLoading, $ionicActionSheet) {
    this.popup = showPopup;

    function showPopup(collection) {
      var sheet = {};

      sheet.buttons = [];
      sheet.buttons.push({
        text: '<i class="icon ion-at"></i> 分享给微信小伙伴'
      }, {
        text: '<i class="icon ion-chatbubbles"></i> 分享到微信朋友圈' 
      }, {
        text: '<i class="icon ion-star"></i> 添加到微信收藏夹' 
      });

      sheet.titleText = '与朋友们分享好图';
      sheet.cancelText = '算了';
      sheet.buttonClicked = buttonClicked;

      $ionicActionSheet.show(sheet);

      function buttonClicked(index) {
        if (log) log(collection);
        if (!window.Wechat) return;

        var title = collection.post.title;
        var thumbnail = collection.images ? collection.images[0] : null;
        var description = collection.post.site && collection.post.site.description ? 
          collection.post.site.description : '';

        if (thumbnail && thumbnail.excerpt)
          title += (' - ' + thumbnail.excerpt);
        if (collection.post && collection.post.author && collection.post.author.name)
          title += (' @' + collection.post.author.name);

        description += ' 图虫日报，精选每日图虫热门图片。'

        Wechat.share({
          message: {
           title: title,
           description: description,
           thumb: thumbnail ? thumbnail.uri_grid + '.jpg': 'http://ww2.sinaimg.cn/large/61ff0de3gw1emj19ju7p4j2030030745.jpg' ,
           media: {
             type: Wechat.Type.WEBPAGE,
             webpageUrl: collection.post.url
           }
         },
         scene: index
        }, function() {
          if (log) log('Shared !');
        }, function(err) {
          if (log) log(err);
        });
      }
    }
  }

})(window.angular, window.debug);