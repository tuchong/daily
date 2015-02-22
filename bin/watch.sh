#!/bin/bash

node_modules/.bin/rewatch \
  src/less/*.less \
  src/javascript/*.js \
  src/javascript/**/*.js \
  -c 'npm run build-js'