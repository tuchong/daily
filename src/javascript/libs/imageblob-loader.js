var URL = window.URL || window.webkitURL;

var BlobManager = {
  blobs: {},
  addBlob: function(blob) {
    var url = URL.createObjectURL(blob);
    var id  = Math.random().toString(32).substr(2);

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

      var blob = new Blob([ arrayBuffer ], { type: mime });
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
      
      return callback(null, img, BlobManager.getBlobById(id));
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

var MinStoring = {
  storeBlob: function(blob, callback) {
    this.createDataURL(blob, function(err, dataURL) {
      if (err) {
        return callback(err);
      }

      var multi = min.multi();

      var key = Math.random().toString(32).substr(2);

      multi
        .sadd('img-caches', key)
        .set('img-cache:' + key, dataURL)
        .exec(function(err) {
          if (err) {
            return callback(err);
          }

          callback(null, key);
        });
    });
  },

  loadImage: function(id, callback) {
    min.get('img-cache:' + id, function(err, dataURL) {
      if (err) {
        return console.error(err);
      }

      ImageLoader.createImage(dataURL, callback);
    });
  },

  createDataURL: function(blob, callback) {
    var reader = new window.FileReader();
    reader.onloadend = function() {
      var dataURL = reader.result;
      return callback(null, dataURL);
    };
    reader.readAsDataURL(blob);
  },

  removeBlob: function(key, callback) {
    min.multi()
      .srem('img-caches', key)
      .del('img-cache:' + key)
      .exec(callback);
  }
};
