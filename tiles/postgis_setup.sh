#!/bin/bash
# Setup postgis user and db (should be run as root)

# start postgres
service postgresql start

# add .pgpass pwd file to eliminate password prompt for tiles user
sudo -u tiles grep "tiles" /home/tiles/.pgpass > /dev/null || sudo -u tiles echo "*:*:*:tiles:tiles" | sudo -u tiles tee -a /home/tiles/.pgpass > /dev/null
sudo -u tiles chmod 600 /home/tiles/.pgpass

# create tiles user and set password
sudo -u postgres psql -c "CREATE ROLE tiles SUPERUSER LOGIN PASSWORD 'tiles';"
sudo -u postgres psql -c "CREATE DATABASE osm_grid OWNER tiles;" 
sudo -u postgres psql -d osm_grid -c "CREATE EXTENSION postgis;" 
sudo -u postgres psql -d osm_grid -c "CREATE EXTENSION hstore;" 
