#!/bin/bash

# Assumes postgis db has been setup and osm2pgsql has been installed

# setup osm-utils
cd # in case we're not in user dir
sudo apt-get -y install ruby-dev
git clone https://github.com/chrisnatali/osm-utils.git
gem install --user-install nokogiri

# create sync data dir
mkdir sync_load

# TODO:  
# - Update osm-utils/sync_load_cfg.rb to point to api server
# - add cronjob to update tile db:
#   crontab -u tiles osm-utils/sync_tile_db.crt

