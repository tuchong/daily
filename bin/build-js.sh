#!/bin/bash

node_modules/.bin/uglifyjs \
  src/javascript/app.js \
  src/javascript/services/store.js \
  src/javascript/services/share.js \
  src/javascript/services/imageloader.js \
  src/javascript/controllers/home.js \
  --mangle \
  --compress \
  -o www/dist/javascript/tuchong.min.js \
  --source-map www/dist/javascript/tuchong.min.js.map \
  --source-map-url tuchong.min.js.map 