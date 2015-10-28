#!/bin/bash
sudo apt-get -y update

# setup requirements for tile server
sudo apt-get -y install git curl tmux postgresql-9.3 postgresql-9.3-postgis-2.1 python-dev libgeos-dev
sudo apt-get -y install make cmake g++ libboost-dev libboost-system-dev \
  libboost-filesystem-dev libboost-thread-dev libexpat1-dev zlib1g-dev \
  libbz2-dev libpq-dev libgeos-dev libgeos++-dev libproj-dev lua5.2 \
  liblua5.2-dev

# For osm data sync we use osmosis and osm2pgsql and osmconvert (in osmctools)
# build osm2pgsql to get the latest since apt pkg version doesn't apply data diffs
cd # in case we're not in user dir
git clone https://github.com/openstreetmap/osm2pgsql.git
cd osm2pgsql
mkdir build && cd build
cmake ..
make
sudo make install
cd

sudo apt-get -y install osmosis osmctools
