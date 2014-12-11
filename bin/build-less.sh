#!/bin/bash

node_modules/.bin/lessc \
  -x src/less/app.less \
  www/dist/css/app.min.css