#!/bin/bash
# setup database for osm

# startup postgres
service postgresql start

timeout_seconds=8
while ( ! sudo service postgresql status | grep online )
do
  [[ $timeout_seconds > 0 ]] || ( echo "failed to start postgres" >&2; exit 1; ) 
  timeout_seconds=$((timeout_seconds-1))
  sleep 1
done

# Ensure that template0 has proper encoding (UTF8), collation and ctype
sudo -u postgres psql -c "update pg_database set encoding=6, datcollate='en_US.UTF-8', datctype='en_US.UTF-8' where datname='template0';"
   
# create osm user and set password as needed
sudo -u postgres psql -c "CREATE ROLE osm SUPERUSER LOGIN PASSWORD 'osm';"
# create prod, test and dev db's
sudo -u postgres psql -c "CREATE DATABASE osm OWNER osm ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE template0;"
sudo -u postgres psql -c "CREATE DATABASE osm_test OWNER osm ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE template0;"
sudo -u postgres psql -c "CREATE DATABASE osm_dev OWNER osm ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE template0;"

# add btree capability to each db
sudo -u postgres psql -d osm -c "CREATE EXTENSION btree_gist;"
sudo -u postgres psql -d osm_dev -c "CREATE EXTENSION btree_gist;"
sudo -u postgres psql -d osm_test -c "CREATE EXTENSION btree_gist;"

