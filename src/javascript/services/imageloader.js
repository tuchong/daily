;(function(window) {
  'use strict';

  var angular = window.angular;
  var localStorage = window.localStorage;

  angular
    .module('tuchong-daily')
    .service('imageLoader', [
      'UI',
      '$timeout',
      imageLoader
    ]);

  function imageLoader(UI, $timeout) {
    var self = this;
    this.load = loadBackground;
    this.loadCache = loadCache;
    this.cache = {};

    var URL = window.URL || window.webkitURL;

    var BlobManager = {
      blobs: {},
      addBlob: function(blob) {
        var url = URL.createObjectURL(blob);
        var id = Math.random().toString(32).substr(2);

        this.blobs[id] = {
          url: url,
          blob: blob
        };

        return id;
      },

      addBlobAttr: function(id, key, value) {
        this.blobs[id][key] = value
      },

      getBlobById: function(id) {
        var blob = this.blobs[id].blob;
        blob.url = this.blobs[id].url;
        return blob;
      },

      getBlobByURL: function(url) {
        var self = this;
        var keys = Object.keys(this.blobs);

        return (function loop(ii) {
          var id = keys[ii];

          if (!id) return null;

          if (self.blobs[id].url === url) {
            var blob = self.blobs[id].blob;
            blob.url = url;
            return blob;
          }

          return loop(++ii);
        })(0);
      },

      removeBlobById: function(id) {
        var url = this.blobs[id].url;

        URL.revokeObjectURL(url);

        delete this.blobs[id];
      },

      removeBlobByURL: function(url) {
        var self = this;

        this.forEachBlobs(function(blob) {
          return blob.url === url;
        }, function(blob, id, blobs) {
          URL.revokeObjectURL(blob.url);
          delete blobs[id];
        });
      },

      forEachBlobs: function(filter, processor) {
        var self = this;
        var keys = Object.keys(this.blobs);

        (function loop(ii) {
          var id = keys[ii];

          if (!id) return;

          if (filter(self.blobs[id])) {
            return processor(self.blobs[id], id, self.blobs);
          }

          return loop(++ii);
        })(0);
      }
    };

    var ImageLoader = {
      loadImage: function(url, callback) {
        var id = null;

        var xhr = new XMLHttpRequest();
        xhr.responseType = 'arraybuffer';
        xhr.open('GET', url, true);

        xhr.onload = function(evt) {
          var arrayBuffer = new Uint8Array(this.response);
          var mime = xhr.getResponseHeader('Content-Type');
          mime = mime ? mime.split(';')[0] : 'image/jpeg';

          var blob = new Blob([arrayBuffer], {
            type: mime
          });
          id = BlobManager.addBlob(blob);
          BlobManager.addBlobAttr(id, 'originURL', url);

          callback(null, BlobManager.getBlobById(id).url, id);
        };

        xhr.onerror = function(evt) {
          return callback(evt.error);
        };

        xhr.send();
      },

      createImage: function(url, callback) {
        this.loadImage(url, function(err, blobUrl, id) {
          if (err) {
            return callback(err);
          }

          var img = new Image();
          img.src = blobUrl;

          return callback(null, img);
        });
      },

      releaseImage: function(url) {
        BlobManager.forEachBlobs(function(blob) {
          return blob.originURL === url;
        }, function(blob, id, blobs) {
          URL.revokeObjectURL(blob.url);
          delete blobs[id];
        });
      }
    };

    function loadCache(type) {
      if (!self.cache[type])
        return [];
      return self.cache[type];
    }

    // 应该将逻辑统一化
    function loadBackground(index, scope, type, id) {
      if (index === undefined || index === null || isNaN(index))
        return;

      if (scope.backgrounds[index]) {
        if (!scope.slidesReady)
          scope.slidesReady = true;

        return UI.loading.hide();
      }

      if (!scope.collections && !scope.images) {
        UI.loading
          .show('图片加载失败，请稍后再试试..');

        $timeout(UI.loading.hide, 400);

        return;
      }

      UI.loading
        .show('<i class="icon ion-loading-c"></i> 图片加载中...');

      var image = type === 'home' ?
        scope.collections[index].images[0].uri :
        scope.images[index].uri;

      loadImage(image, loadDone, loadError);

      function loadDone() {
        scope.backgrounds[index] = image;
        scope.$apply();

        if (!scope.slidesReady)
          scope.slidesReady = true;

        // Update the whole cache
        var cacheKey = type === 'home' ? type : id;
        self.cache[cacheKey] = scope.backgrounds;

        UI.loading.hide();
      }

      function loadError() {
        UI.loading
          .show('图片加载失败，请稍后再试试...');
      }
    }

    function loadImage(uri, callback, onerror) {
      ImageLoader.createImage(
        uri + '.jpg', 
        function(err, img) {
        img.onload = callback;
        img.onerror = onerror;
        img = null;
      });
    }
  }

})(this);
