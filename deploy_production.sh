#!/bin/bash
# To be run as osm user

# update code from repo
cd /home/osm/openstreetmap-website/
git pull
if [[ $# -gt 0 ]]; then
  branch=$1
  git checkout $branch
fi

# install gems
bundle install 

# migrate db changes if needed
RAILS_ENV=production rake db:migrate

# precompile assets (js, etc)
RAILS_ENV=production rake assets:precompile

# restart
sudo service apache2 restart
