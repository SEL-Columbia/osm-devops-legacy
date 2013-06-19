Scripts associated with OSM RailsPort deployment on Ubuntu 12.04 server

Perform the following tasks to setup a VM or Sandbox:
* vm_osm is a known host with a blank Ubuntu 12.04 server installed
* vm_osm_osm is a host login as the osm user

1.  Setup server and osm prereqs:
    ssh vm_osm OSM_PWD=<osm_pwd> bash -s < bootstrap.sh
   
2.  Setup postgres:
    ssh vm_osm bash -s < osm_postgres.sh  

3.  Add your authorized_key to osm user account to connect without pwd as the osm user
    
4.  Get the openstreetmap-website src fork from modilabs repo:
    ssh vm_osm_osm bash -s < osm_site_setup.sh

5.  Setup the db, gems and run tests for openstreetmap-website:
    ssh vm_osm_osm OSM_PWD=<osm_db_user_pwd> bash -s < osm_post_site_setup.sh 
