#!/bin/bash
# setup database access for osm

# add .pgpass pwd file to eliminate password prompt for osm use
echo "*:*:*:osm:osm" > /home/osm/.pgpass
chmod 600 /home/osm/.pgpass


