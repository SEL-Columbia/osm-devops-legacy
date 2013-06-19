#!/bin/bash

# do what we need from within the openstreetmap-website dir
cd openstreetmap-website

# assumes postgresql db setup has been run
# Setup the tile functions in the dev/prod db's
psql -d osm_dev -c "CREATE FUNCTION maptile_for_point(int8, int8, int4) RETURNS int4 AS '/home/osm/openstreetmap-website/db/functions/libpgosm', 'maptile_for_point' LANGUAGE C STRICT;"
psql -d osm -c "CREATE FUNCTION maptile_for_point(int8, int8, int4) RETURNS int4 AS '/home/osm/openstreetmap-website/db/functions/libpgosm', 'maptile_for_point' LANGUAGE C STRICT;"
psql -d osm_dev -c "CREATE FUNCTION tile_for_point(int4, int4) RETURNS int8 AS '/home/osm/openstreetmap-website/db/functions/libpgosm', 'tile_for_point' LANGUAGE C STRICT;"
psql -d osm -c "CREATE FUNCTION tile_for_point(int4, int4) RETURNS int8 AS '/home/osm/openstreetmap-website/db/functions/libpgosm', 'tile_for_point' LANGUAGE C STRICT;"

# create database config
cat - > config/database.yml <<EOF
development:
  adapter: postgresql
  database: osm_dev
  username: osm
  password: "$OSM_PWD"
  host: localhost
  encoding: utf8
  template: template0

# Warning: The database defined as 'test' will be erased and
# re-generated from your development database when you run 'rake'.
# Do not set this db to the same as development or production.
test:
  adapter: postgresql
  database: osm_test
  username: osm
  password: "$OSM_PWD"
  host: localhost
  encoding: utf8
  template: template0

production:
  adapter: postgresql
  database: osm
  username: osm
  password: "$OSM_PWD"
  host: localhost
  encoding: utf8
  template: template0
EOF

# Install gems
bundle install

# setup development database
rake db:migrate

# setup prod db
env RAILS_ENV=production rake db:migrate

# run the tests (uses osm_test db)
rake test 
