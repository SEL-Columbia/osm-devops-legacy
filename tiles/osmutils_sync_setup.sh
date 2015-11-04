#!/bin/bash

# Assumes postgis db has been setup and osm2pgsql has been installed

# setup osm-utils
cd # in case we're not in user dir
sudo apt-get -y install ruby-dev
git clone https://github.com/chrisnatali/osm-utils.git
gem install --user-install nokogiri

# create sync data dir
mkdir sync_load
crontab osm-utils/sync_tile_db.crt

# create empty tables via osm2pgsql
sudo service postgresql start
while ! psql -d osm_grid -c '\d' > /dev/null;
do
  echo "waiting for postgres..."
  sleep 1
done

osm2pgsql --database osm_grid -c --style gridmaps.style --slim empty.osm --hstore-all --extra-attributes
