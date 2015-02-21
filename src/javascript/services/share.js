;(function(window) {
  'use strict';

  var angular = window.angular;

  angular
    .module('tuchong-daily')
    .service('share', [
      '$ionicLoading',
      '$ionicActionSheet',
      share
    ]);

  function share($ionicLoading, $ionicActionSheet) {
    this.popup = showPopup;

    function showPopup(image, post) {
      var sheet = {};
      sheet.titleText = '与朋友们分享好图';
      sheet.cancelText = '算了';
      sheet.buttonClicked = buttonClicked;
      sheet.buttons = [{
        text: '<i class="icon ion-at"></i> 分享给微信小伙伴'
      }, {
        text: '<i class="icon ion-chatbubbles"></i> 分享到微信朋友圈' 
      }, {
        text: '<i class="icon ion-star"></i> 添加到微信收藏夹' 
      }];

      $ionicActionSheet.show(sheet);

      function buttonClicked(index) {
        if (!window.Wechat) return;

        var title = post.title;
        var thumbnail = image || null;
        var description = post.site && post.site.description ? 
          post.site.description : '';

        if (thumbnail && thumbnail.excerpt)
          title += (' - ' + thumbnail.excerpt);
        if (post && post.author && post.author.name)
          title += (' @' + post.author.name);

        description += ' 图虫日报，精选每日图虫热门图片。'

        Wechat.share({
          message: {
           title: title,
           description: description,
           thumb: thumbnail ? thumbnail.uri_grid + '.jpg': 'http://ww2.sinaimg.cn/large/61ff0de3gw1emj19ju7p4j2030030745.jpg' ,
           media: {
             type: Wechat.Type.WEBPAGE,
             webpageUrl: post.url
           }
         },
         scene: index
        });
      }
    }
  }

})(this);