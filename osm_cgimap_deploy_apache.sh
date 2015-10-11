#!/bin/bash
# To be run as root user
# Assumes cgimap has been installed via osm_cgimap.sh
# setup cgimap to run via an init.d service and have apache route to it
# This offloads `map` requests from the rails server 

if [ -z "$OSM_DB_PASSWORD" ] || [ -z "$CGIMAP_PORT" ] || [ -z "$SERVER_NAME" ] || [ -z "$SERVER_PORT" ]; 
then
    echo "variables need to be set:  OSM_DB_PASSWORD, CGIMAP_PORT, SERVER_NAME, SERVER_PORT"
    exit 1
fi

# Setup cgimap as service
# NOTE:  Tried using zerebebuth's method and upstart to no avail...fell back to this
# based on https://github.com/fhd/init-script-template
cat - > /etc/init.d/cgimap << EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides:
# Required-Start:    \$remote_fs \$syslog
# Required-Stop:     \$remote_fs \$syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Manage cgimap daemon
# Description:       Optimized handling of openstreetmap 'map' api requests 
### END INIT INFO

CGIMAP_HOST=localhost; export CGIMAP_HOST
CGIMAP_DBNAME=osm; export CGIMAP_DBNAME
CGIMAP_USERNAME=osm; export CGIMAP_USERNAME
CGIMAP_PASSWORD=$OSM_DB_PASSWORD; export CGIMAP_PASSWORD

CGIMAP_PIDFILE=/home/osm/cgimap.pid; export CGIMAP_PIDFILE
CGIMAP_LOGFILE=/home/osm/cgimap.log; export CGIMAP_LOGFILE

CGIMAP_MEMCACHE=localhost; export CGIMAP_MEMCACHE
CGIMAP_RATELIMIT=102400; export CGIMAP_RATELIMIT
CGIMAP_MAXDEBT=250; export CGIMAP_MAXDEBT

CGIMAP_EXE_PATH=/home/osm/openstreetmap-cgimap/map

get_pid() {
    cat "\$CGIMAP_PIDFILE"
}

is_running() { 
    [ -f "\$CGIMAP_PIDFILE" ] && ps \$( get_pid ) > /dev/null 2>&1
}

case "\$1" in
    start)
    if is_running; then
        echo "Already started"
    else
        echo "Starting \$name"
        start-stop-daemon --start --chuid osm --exec \$CGIMAP_EXE_PATH -- --daemon --port=$CGIMAP_PORT --instances=10 --pidfile=\$CGIMAP_PIDFILE
        if ! is_running; then
            echo "Unable to start, see \$CGIMAP_LOGFILE"
            exit 1
        fi
    fi
    ;;
    stop)
    if is_running; then
        echo -n "Stopping \$name.."
        kill \$( get_pid )
        for i in {1..10}
        do
            if ! is_running; then
                break
            fi

            echo -n "."
            sleep 1
        done
        echo

        if is_running; then
            echo "Not stopped; may still be shutting down or shutdown may have failed"
            exit 1
        else
            echo "Stopped"
            if [ -f "\$CGIMAP_PIDFILE" ]; then
                rm "\$CGIMAP_PIDFILE"
            fi
        fi
    else
        echo "Not running"
    fi
    ;;
    restart)
    \$0 stop
    if is_running; then
        echo "Unable to stop, will not attempt to start"
        exit 1
    fi
    \$0 start
    ;;
    status)
    if is_running; then
        echo "Running"
    else
        echo "Stopped"
        exit 1
    fi
    ;;
    *)
    echo "Usage: \$0 {start|stop|restart|status}"
    exit 1
    ;;
esac
exit 0
EOF

chmod 755 /etc/init.d/cgimap
service cgimap restart

# Setup apache to forward 'map' requests to running cgimap service
# # install required apache modules for fcgi 
a2enmod proxy_http
a2enmod proxy_fcgi 
a2enmod rewrite

mkdir -p /var/www/api
cat - > /etc/apache2/sites-available/osm.conf << EOF
<VirtualHost *:$SERVER_PORT>
  ServerName $SERVER_NAME
  DocumentRoot /home/osm/openstreetmap-website/public
  RailsEnv production
  
  Header set Access-Control-Allow-Origin "*"

  <Directory /home/osm/openstreetmap-website/public>
    Allow from all
    Options -MultiViews
    Require all granted
  </Directory>

  ProxyPassMatch "^/api/0\\.6/map\$" "fcgi://127.0.0.1:$CGIMAP_PORT"
  ErrorLog /var/log/apache2/error.log
  LogLevel warn
  CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF

# enable osm site (if not already) and restart
a2ensite osm 
service apache2 restart
