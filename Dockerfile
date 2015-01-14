# Docker image for openstreetmap-website
# Parameters for scripts defined in environ.cfg
# Each script sources this config for it's variables
# 
# The result of the build will be an image that when run can 
# serve as an openstreetmap-website dev/test/production environment
FROM ubuntu:14.04
MAINTAINER Chris Natali <chris.natali@gmail.com>


# You can modify this users attributes later to suit your needs
# (I set it's uid to my host user uid so that I can edit host mounted files)
RUN useradd -m -G sudo -s /bin/bash osm
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Add scripts that'll do the setup work and then run 'em 
# as appropriate user
ADD bootstrap.sh /tmp/
RUN bash /tmp/bootstrap.sh

ADD osm_pgpass.sh /tmp/
USER osm
RUN bash /tmp/osm_pgpass.sh

USER root
ADD osm_postgres.sh /tmp/
RUN bash /tmp/osm_postgres.sh

USER root
ADD osm_site_setup.sh /tmp/
USER osm
RUN bash /tmp/osm_site_setup.sh

USER root
ADD osm_post_site_setup.sh /tmp/
USER osm
RUN bash /tmp/osm_post_site_setup.sh

USER root
ADD osm_update_sequences.sh /tmp/
RUN bash /tmp/osm_update_sequences.sh
