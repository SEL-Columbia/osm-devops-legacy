#!/bin/bash

sudo apt-get -y install git nodejs-legacy npm
cd # in case we're not in user dir
git clone https://github.com/mapbox/tilemill.git
cd tilemill
npm install 

# start tilemill via:
# ./index.js --config=config.json
