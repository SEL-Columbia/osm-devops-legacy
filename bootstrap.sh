#!/bin/bash

# update locale
locale-gen en_US.UTF-8

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

# install dependencies
apt-get update && apt-get -y install \
  apache2 \
  apache2-threaded-dev \
  build-essential \
  git-core \
  libmagickwand-dev \
  libpq-dev \
  libruby \
  libsasl2-dev \
  libxml2-dev \
  libxslt1-dev \
  nodejs \
  openjdk-7-jre \
  osmosis \
  postgresql \
  postgresql-contrib \
  postgresql-server-dev-all \
  ri \
  ruby-dev \
  ruby1.9.3 \


# update gems
gem install bundler
