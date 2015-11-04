# Docker image for openstreetmap tile server
FROM ubuntu:14.04
MAINTAINER Chris Natali

# You can modify this users attributes later to suit your needs
# (I set it's uid to my host user uid so that I can edit host mounted files)
RUN useradd -m -G sudo -s /bin/bash tiles
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Add scripts that'll do the setup work and then run 'em 
# as appropriate user
ADD bootstrap.sh /tmp/
USER tiles 
RUN bash /tmp/bootstrap.sh

USER root 
ADD postgis_setup.sh /tmp/
RUN bash /tmp/postgis_setup.sh

ADD osmutils_sync_setup.sh /tmp/
USER tiles 
ADD gridmaps.style /home/tiles/gridmaps.style
ADD empty.osm /home/tiles/empty.osm
RUN bash /tmp/osmutils_sync_setup.sh

USER root 
ADD tilemill.sh /tmp/
USER tiles 
RUN bash /tmp/tilemill.sh

USER root
ADD run.sh /tmp/
ADD run_tilemill.sh /tmp/
CMD /tmp/run.sh && /tmp/run_tilemill.sh
