### Deprecated:  May be useful for scripts demonstrating how this was setup via apache without Docker.  For current devops see [new osm-devops repo](https://github.com/SEL-Columbia/osm-devops)

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

    Note:  If you're setting this up in a development Docker container and want to listen for requests from the host on port 8001, you need to add the following to /etc/apache2/apache2.conf:
    ```
    Listen 0.0.0.0:8001
    ```

7.  For setting up cgimap (for faster map api calls):

    ```
    ssh vm_osm_osm bash -s < osm_cgimap.sh
    ```
    
    You will then need to configure lighttpd, etc  
    See the following github repo for more:
    https://github.com/zerebubuth/openstreetmap-cgimap

### Development workflow

Development for the openstreetmap-website fork should be done in the SEL-Columbia/openstreetmap-website repository.  

#### Branch organization:
- master:  should be synchronized with upstream openstreetmap/openstreetmap-website regularly (fork changes are not applied here)
- gridmaps:  "production" SEL openstreetmap-website fork.  This should be deployable at all times.  Nothing untested should make it in here.
- gridmaps-<branch>:  Any changes to fork code to be merged in a pull-request to gridmaps

#### Testing

Testing can be done via Docker by bringing up a preconfigured container, pointing it to the git branch directory on the host and running the tests.  
The following command assumes a preconfigured image named:tagged osm-website:stage.

```
docker run -ti --rm -u osm -v "<your_host_osm_website_dir>:/osm-src" --name osm-test osm-website:stage /bin/bash
```

Then, from the console in that container run the tests.

```
sudo service postgresql start
cd /osm-src
rake test
```

Once a branch has been tested in a dev environment, it can be merged into the gridmaps branch.  
From there it can be deployed to a previously configured environment.

#### Production Deployment

Currently, deployment involves running bash scripts on an Ubuntu server (keeping DevOps simple, flexible and generic...though somewhat fragmented).  

Building and deploying cgimap for production:

```
ssh osm@<host> bash -s < osm_cgimap_build.sh

ssh root@<host> OSM_DB_PASSWORD=osm CGIMAP_PORT=31337 SERVER_NAME=<host> SERVER_PORT=80 bash -s < osm_cgimap_deploy_apache.sh
```

Deploying to existing production environment (assumes everything has been setup)

```
ssh osm@<host> bash -s < deploy_production.sh
```

Deploying an alternative branch to an environment can be done via:

```
cat deploy_production.sh | ssh osm@<host> bash -s -- gridmaps-<branch>
```


