#!/bin/bash
# Install OSM site

# Get the openstreetmap website
if [ ! -d /home/osm/openstreetmap-website ]
then
  git clone git@github.com:modilabs/openstreetmap-website.git
fi

# Make the libpgosm shared object lib
cd /home/osm/openstreetmap-website/db/functions
make libpgosm.so
cd

