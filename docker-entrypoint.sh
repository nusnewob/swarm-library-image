#!/bin/dumb-init /bin/sh
set -e

# Note above that we run dumb-init as PID 1 in order to reap zombie processes
# as well as forward signals to all processes in its session. Normally, sh
# wouldn't do either of these functions so we'd leak zombies as well as do
# unclean termination of all our sub-processes.

# Fix AWS ECS
if [ -z "$SWARM_ADVERTISE_PORT" ]; then
  SWARM_ADVERTISE_PORT=2375
fi

SWARM_ADVERTISE=
if [ -z "$SWARM_ADVERTISE" ]; then
  SWARM_ADVERTISE_ADDRESS=$(curl 169.254.169.254/latest/meta-data/local-ipv4 2> /dev/null)
  if [ -z "$SWARM_ADVERTISE_ADDRESS" ]; then
    echo "Could not find IP to advertise, exiting"
    exit 1
  fi

  SWARM_ADVERTISE="--advertise=$SWARM_ADVERTISE_ADDRESS:$SWARM_ADVERTISE_PORT"
  echo "==> Found address '$SWARM_ADVERTISE_ADDRESS' to advertise, setting advertise option..."
fi

# Look for Swarm subcommands.
if [ "$1" = 'manage' ]; then
    shift
    set -- swarm manage \
        $SWARM_ADVERTISE \
        "$@"
elif [ "$1" = 'join' ]; then
    shift
    set -- swarm join \
        $SWARM_ADVERTISE \
        "$@"
else
    set -- swarm "$@"
fi

exec "$@"
