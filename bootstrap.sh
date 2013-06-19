#!/bin/bash

# Do everything as root (preserve env vars via -E)
sudo -E su

if [ -z $OSM_PWD ]; then echo "Need to set OSM_PWD"; fi

# update apt repo
apt-get update

# ensure that the sudo group exists and has NOPASSWD sudo perms
groupadd sudo

grep -v '%sudo' /etc/sudoers > tmp.sudoers
echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> tmp.sudoers
cat tmp.sudoers > /etc/sudoers
rm tmp.sudoers

# add osm user (change pwd as needed)
if ! id -u osm > /dev/null
then
    useradd -p $(perl -e'print crypt("'$OSM_PWD'", "aa")') -s "/bin/bash" -U -m -G sudo osm
fi

# update locale
# locale-gen en_US.UTF-8

# Set lang so UTF-8 config settings of postgresql use UTF-8 on install
export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# set lang for all profiles
cat - > /etc/profile.d/lang.sh <<EOF
export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
EOF


# add osm user to admin group?
# install dependencies
apt-get -y install ruby1.9.3 libmagickwand-dev libxml2-dev libxslt1-dev apache2 apache2-threaded-dev build-essential git-core postgresql postgresql-contrib libpq-dev postgresql-server-dev-9.1 libsasl2-dev openjdk-7-jre osmosis 

# update gems
gem install bundler
