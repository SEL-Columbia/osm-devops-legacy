#!/bin/bash
# To be run as osm user
# Builds cgimap
# This offloads `map` requests from the rails server 
# to a separate server/process

sudo apt-get -y install git build-essential automake autoconf libtool
sudo apt-get -y install \
libxml2-dev \
libpqxx3-dev \
libfcgi-dev \
libboost-dev \
libboost-regex-dev \
libboost-program-options-dev \
libboost-date-time-dev \
libboost-filesystem-dev \
libboost-system-dev \
libmemcached-dev \
zlib1g-dev

git clone git://github.com/zerebubuth/openstreetmap-cgimap.git
cd openstreetmap-cgimap
./autogen.sh
./configure --with-fcgi=/usr --with-boost-libdir=/usr/lib/x86_64-linux-gnu
make
 
# For running via a service within apache see/run osm_cgimap_apache.sh
#
# For running via lighttpd:
# - Copy cgimap_lighttpd.conf from here to openstreetmap-cgimap dir
# - Start up cgimap via `lighttpd -D -f cgimap_lighttpd.conf`
# - In the openstreetmap-website/config/application.yml, modify server_map_url 
#   to point to `http://localhost:8126` 
#   (or the port you assign in cgimap_lighttpd.conf)
# - Uncomment the line redirecting 'api/0.6/map' calls to the SERVER_MAP_URL
#   (and comment out the non-redirecting route)
# - Restart rails (or apache) server
