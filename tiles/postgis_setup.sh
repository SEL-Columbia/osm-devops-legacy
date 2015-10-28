#!/bin/bash
# Setup postgis user and db (should be run as root)

# start postgres
service postgresql start

# add .pgpass pwd file to eliminate password prompt for tiles user
sudo -u tiles -i
grep "tiles" .pgpass > /dev/null || echo "*:*:*:tiles:tiles" >> .pgpass
chmod 600 .pgpass
exit

sudo -u postgres -i

# create tiles user and set password
psql -c "CREATE ROLE tiles SUPERUSER LOGIN PASSWORD 'tiles';"

psql -c "CREATE DATABASE osm_grid OWNER tiles;" 
psql -d osm_grid -c "CREATE EXTENSION postgis;" 
psql -d osm_grid -c "CREATE EXTENSION hstore;" 
