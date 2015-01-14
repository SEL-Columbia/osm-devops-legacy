#!/bin/bash
# Install OSM site

# Get the openstreetmap website
if [ ! -d /home/osm/openstreetmap-website ]
then
  cd /home/osm
  curl --location https://github.com/SEL-Columbia/openstreetmap-website/archive/master.tar.gz | tar xz
  mv openstreetmap-website-master openstreetmap-website
fi

# Make the libpgosm shared object lib
cd /home/osm/openstreetmap-website/db/functions
make libpgosm.so
cd
