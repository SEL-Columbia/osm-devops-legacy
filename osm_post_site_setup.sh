#!/bin/bash

# start postgres
sudo service postgresql start

timeout_seconds=10
while ( ! sudo service postgresql status | grep -q online )
do
  [[ $timeout_seconds > 0 ]] || { echo "failed to connect to postgres" >&2; exit 1; } 
  timeout_seconds=$((timeout_seconds-1))
  sleep 1
done

# do what we need from within the openstreetmap-website dir
cd /home/osm/openstreetmap-website

# copy over example.application.yml as application.yml since certain 
# variables are needed to allow rails environment to startup.
# NOTE:  To make the environment fully functional, replace 
# config/application.yml with custom one
cp config/example.application.yml config/application.yml

# Install gems
bundle install

# create database config
cat - > config/database.yml <<EOF
development:
  adapter: postgresql
  database: osm_dev
  username: osm
  password: osm
  host: localhost
  encoding: utf8

# Warning: The database defined as 'test' will be erased and
# re-generated from your development database when you run 'rake'.
# Do not set this db to the same as development or production.
test:
  adapter: postgresql
  database: osm_test
  username: osm
  password: osm
  host: localhost
  encoding: utf8

production:
  adapter: postgresql
  database: osm
  username: osm
  password: osm
  host: localhost
  encoding: utf8
EOF

# create prod, test and dev db's
rake db:create:all

# add btree capability to each db
sudo -u postgres psql -d osm -c "CREATE EXTENSION btree_gist;"
sudo -u postgres psql -d osm_dev -c "CREATE EXTENSION btree_gist;"
sudo -u postgres psql -d osm_test -c "CREATE EXTENSION btree_gist;"

# assumes postgresql db setup has been run
# Setup the tile functions in the dev/prod db's
psql -d osm_dev -c "CREATE FUNCTION maptile_for_point(int8, int8, int4) RETURNS int4 AS '`pwd`/db/functions/libpgosm', 'maptile_for_point' LANGUAGE C STRICT;"
psql -d osm_dev -c "CREATE FUNCTION tile_for_point(int4, int4) RETURNS int8 AS '`pwd`/db/functions/libpgosm', 'tile_for_point' LANGUAGE C STRICT;"
psql -d osm_dev -c "CREATE FUNCTION xid_to_int4(xid) RETURNS int4 AS '`pwd`/db/functions/libpgosm', 'xid_to_int4' LANGUAGE C STRICT;"
psql -d osm -c "CREATE FUNCTION maptile_for_point(int8, int8, int4) RETURNS int4 AS '`pwd`/db/functions/libpgosm', 'maptile_for_point' LANGUAGE C STRICT;"
psql -d osm -c "CREATE FUNCTION tile_for_point(int4, int4) RETURNS int8 AS '`pwd`/db/functions/libpgosm', 'tile_for_point' LANGUAGE C STRICT;"
psql -d osm -c "CREATE FUNCTION xid_to_int4(xid) RETURNS int4 AS '`pwd`/db/functions/libpgosm', 'xid_to_int4' LANGUAGE C STRICT;"

# setup development database
rake db:migrate

# TODO:  test db should not need to be explicitly migrated (should be done as part of test run)
env RAILS_ENV=test rake db:migrate

# setup prod db
env RAILS_ENV=production rake db:migrate

# run the tests (uses osm_test db)
rake test 

# exit with success despite failures in test for now
exit 0
