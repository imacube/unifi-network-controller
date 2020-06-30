#!/usr/bin/env bash

# set -x

########################################################
# Start and stop the necessary services and handle basic
# administrative tasks.
########################################################

MONGODB=/etc/init.d/mongodb
UNIFI=/etc/init.d/unifi

shutdown() {
	echo "Stopping services"
	${UNIFI} stop
	${MONGODB} stop
	echo 'Services Stopped'
}

trap shutdown 15

chown -R unifi:unifi /var/lib/unifi
chown -R unifi:unifi /var/log/unifi
chown -R mongodb:mongodb /var/lib/mongodb
chown -R mongodb:mongodb /var/log/mongodb

${MONGODB} start
${UNIFI} start

tail --pid=$(cat /var/run/unifi.pid) -f /dev/null &
wait
echo 'End of docker-entrypoint.bash'
