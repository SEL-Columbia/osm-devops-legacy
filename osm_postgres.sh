#!/bin/bash
# setup database for osm

# add .pgpass pwd file to eliminate password prompt for osm use
sudo -u osm -i
echo "*:*:*:osm:osm" > .pgpass
chmod 600 .pgpass
exit

sudo -u postgres -i
# Ensure that template0 has proper encoding (UTF8), collation and ctype
psql -c "update pg_database set encoding=6, datcollate='en_US.UTF-8', datctype='en_US.UTF-8' where datname='template0';"

# create osm user and set password as needed
psql -c "CREATE ROLE osm SUPERUSER LOGIN PASSWORD 'osm';"
# create prod, test and dev db's
psql -c "CREATE DATABASE osm OWNER osm ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE template0;"
psql -c "CREATE DATABASE osm_test OWNER osm ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE template0;"
psql -c "CREATE DATABASE osm_dev OWNER osm ENCODING 'UTF8' LC_COLLATE 'en_US.UTF-8' LC_CTYPE='en_US.UTF-8' TEMPLATE template0;"

# add btree capability to each db
psql -d osm -c "CREATE EXTENSION btree_gist;"
psql -d osm_dev -c "CREATE EXTENSION btree_gist;"
psql -d osm_test -c "CREATE EXTENSION btree_gist;"
exit


