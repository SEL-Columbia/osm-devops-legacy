#!/bin/bash

# Install and setup apache + passenger to serve openstreetmap-website
# First apache2
apt-get install apache2
# Run apache as osm user
sed -i 's/www-data/osm/' /etc/apache2/envvars

# Configure osm site in apache
cat - > /etc/apache2/sites-available/osm << EOF
<VirtualHost *:80>
  DocumentRoot /home/osm/openstreetmap-website
  RailsEnv production

  <Directory /home/user/openstreetmap-website/public>
    Allow from all
    Options -MultiViews
  </Directory>

  ErrorLog ${APACHE_LOG_DIR}/error.log
  LogLevel warn
  CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

unlink /etc/apache2/sites-enabled/*
ln -s /etc/apache2/sites-available/osm /etc/apache2/sites-enabled/osm

# Setup passenger
apt-get -y install libcurl4-openssl-dev
gem install passenger
passenger-install-apache2-module -a

cat - > /etc/apache2/conf.d/passenger << EOF
LoadModule passenger_module /var/lib/gems/1.9.1/gems/passenger-3.0.19/ext/apache2/mod_passenger.so
PassengerRoot /var/lib/gems/1.9.1/gems/passenger-3.0.19
PassengerRuby /usr/bin/ruby1.9.1
EOF

# precompile assets (js, etc)
cd /home/osm/openstreetmap-website/
bundle exec rake assets:precompile

service apache2 restart
