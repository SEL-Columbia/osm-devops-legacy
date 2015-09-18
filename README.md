Dockerfile and scripts associated with 
[SEL Fork of OSM Rails Port](https://github.com/SEL-Columbia/openstreetmap-website) 
deployment on an Ubuntu 14.04 server.  These are intended to be used for 
development and as a guide to deployment. 

### Docker setup

Assuming you have [Docker](docker.com) (or boot2docker) installed and started, you can start
a server via the following steps:

1.  Pull the osm-website image from [dockerhub](https://hub.docker.com):

    ```
    docker pull cjon/osm-website
    ```

2.  Start the container, exposing port 3000 and dropping into a bash shell:

    ```
    docker run -ti -p 3000:3000 cjon/osm-website /bin/bash
    ```

3.  Start postgres, switch to osm user and start rails:

    ```
    service postgresql start
    su - osm
    cd openstreetmap-website
    rails s -b 0.0.0.0
    ```

You should now be able to access the site at 0.0.0.0:3000.

To do anything useful with the [openstreetmap api](http://wiki.openstreetmap.org/wiki/API_v0.6), you'll need to add a user.  You can do this via rails and [these instructions](https://github.com/openstreetmap/openstreetmap-website/blob/master/CONFIGURE.md#managing-users).  

Remember, docker containers are "stateless", so any changes made during 
your session will be lost.  You can extend the image with your own 
customizations via the `docker commit` command.  See the 
[docker docs](https://docs.docker.com) for more.  

### Dev environment setup (via Docker)

A development environment can leverage the image created above (for the libraries, database, etc), yet run the source from a host mounted dir.  This is a useful way to isolate your host environment from all that openstreetmap depends on.  

From your openstreetmap-website source directory, run the following (assumes you have the cjon/osm-website image on your host, replace as appropriate):

```
docker run -it --rm -p 3000:3000 -v "$(pwd):/osm-src" -u $UID --name osm-dev cjon/osm-website /bin/bash
```

This will run the osm-website image with your host openstreetmap-website source mounted in the /osm-src dir in the container and port 3000 exposed to the host.  The UID of the user should match yours on your host.  It will also drop you into a bash shell.  

In the container's bash shell, run the following to startup your dev site:
```
cd osm-src
service postgresql start
rake db:migrate RAILS_ENV=development
rails s -b 0.0.0.0
```

You should now be able to open up http://127.0.0.1:3000 in your hosts browser and test out the dev site.  

It may be useful to create an osm user with administrator permissions.  To do so, follow [instructions here](https://github.com/SEL-Columbia/openstreetmap-website/blob/master/CONFIGURE.md#managing-users)

Your database will be reset on each start of your docker container, but you can commit a new container that retains the database changes via the following:

```
docker commit osm-dev osm-website:dev
```


### VM or Dev machine setup

Perform the following tasks to setup a VM or Dev box for development.

Assumptions:

* vm_osm is a known host with a blank Ubuntu server installed
* vm_osm_osm is a host login as the osm user with authorized_key access and ssh agent forwarding enabled

Instructions:

1.  Setup server and osm prereqs:

    ```
    ssh vm_osm bash -s < bootstrap.sh
    ```
   
2.  Setup postgres:

    ```
    ssh vm_osm_osm bash -s < osm_pgpass.sh  
    ssh vm_osm bash -s < osm_postgres.sh  
    ```
    
3.  Get the openstreetmap-website src fork from SEL github repo:
    (gets archive of repo and unzips it)

    ```
    ssh vm_osm_osm bash -s < osm_site_setup.sh
    ```

4.  Update configuration (config/application.yml) with appropriate ip address, mail server...

5.  Setup the db, gems and run tests for openstreetmap-website:

    ```
    ssh vm_osm_osm bash -s < osm_post_site_setup.sh 
    ```

6.  For prod, setup apache + passenger, precompile rails assets ('asset pipeline') and start serving

    ```
    ssh vm_osm_osm bash -s < apache_passenger.sh
    ```

    Then modify /etc/apache2/sites-available/osm.conf with appropriate ServerName value

7.  For setting up cgimap (for faster map api calls):

    ```
    ssh vm_osm_osm bash -s < osm_cgimap.sh
    ```
    
    You will then need to configure lighttpd, etc  
    See the following github repo for more:
    https://github.com/zerebubuth/openstreetmap-cgimap
