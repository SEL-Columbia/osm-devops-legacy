#!/bin/bash
# setup cgimap

sudo apt-get -y install libxml2-dev libpqxx3-dev libfcgi-dev libboost-dev libboost-regex-dev libboost-program-options-dev libboost-date-time-dev libmemcached-dev libapache2-mod-fcgid build-essential automake autoconf
git clone git://github.com/SEL-Columbia/openstreetmap-cgimap.git
cd openstreetmap-cgimap
./autogen.sh
./configure --with-fcgi=/usr
make


