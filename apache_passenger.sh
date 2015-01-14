#!/bin/bash
# To be run as osm user

# Install and setup apache + passenger to serve openstreetmap-website
# First apache2
sudo apt-get install -y apache2

# Run apache as osm user
sudo sed -i 's/www-data/osm/' /etc/apache2/envvars

# install apache module to allow header config
sudo a2enmod headers

# get rid of any existing conf
sudo rm /etc/apache2/conf-enabled/passenger.conf
sudo rm /etc/apache2/sites-enabled/osm.conf

# Setup passenger
sudo apt-get -y install libcurl4-openssl-dev
sudo gem install passenger
sudo passenger-install-apache2-module -a

sudo updatedb

sudo su
cat - > /etc/apache2/conf-available/passenger.conf << EOF
LoadModule passenger_module `locate mod_passenger.so | head -1`
PassengerRoot /var/lib/gems/1.9.1/gems/passenger-`passenger --version | sed -n '1p' | awk '{print $4}'`
PassengerRuby /usr/bin/ruby1.9.1
EOF
exit

sudo ln -s /etc/apache2/conf-available/passenger.conf /etc/apache2/conf-enabled/passenger.conf

# Configure osm site in apache
sudo su
cat - > /etc/apache2/sites-available/osm.conf << EOF
<VirtualHost *:80>
  # ServerName gridmaps.org
  DocumentRoot /home/osm/openstreetmap-website/public
  RailsEnv production
  
  Header set Access-Control-Allow-Origin "*"

  <Directory /home/osm/openstreetmap-website/public>
    Allow from all
    Options -MultiViews
    Require all granted
  </Directory>

  ErrorLog /var/log/apache2/error.log
  LogLevel warn
  CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF
exit 

sudo ln -s /etc/apache2/sites-available/osm.conf /etc/apache2/sites-enabled/osm.conf

# precompile assets (js, etc)
cd /home/osm/openstreetmap-website/
RAILS_ENV=production rake assets:precompile

# set the secret key for passenger in the osm users bashrc (only if it's not currently set)
echo "export SECRET_KEY_BASE=`rake secret`" >> tmp.secret
sudo su
grep "SECRET_KEY_BASE" /etc/apache2/envvars || cat tmp.secret >> /etc/apache2/envvars
exit
rm tmp.secret

sudo service apache2 restart
