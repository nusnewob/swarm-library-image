#!/bin/dumb-init /bin/sh
set -e

# Note above that we run dumb-init as PID 1 in order to reap zombie processes
# as well as forward signals to all processes in its session. Normally, sh
# wouldn't do either of these functions so we'd leak zombies as well as do
# unclean termination of all our sub-processes.

# Fix AWS ECS
SWARM_ADVERTISE=
if [ -z "$SWARM_ADVERTISE" ]; then
  SWARM_ADVERTISE_ADDRESS=$(curl 169.254.169.254/latest/meta-data/local-ipv4 2> /dev/null)
  if [ -z "$SWARM_ADVERTISE_ADDRESS" ]; then
    echo "Could not find IP to advertise, exiting"
    exit 1
  fi

  SWARM_ADVERTISE="--advertise=$SWARM_ADVERTISE_ADDRESS"
  echo "==> Found address '$SWARM_ADVERTISE_ADDRESS' to advertise, setting advertise option..."
fi

# If the user is trying to run Swarm directly with some arguments, then
# pass them to Swarm.
if [ "${1:0:1}" = '-' ]; then
    set -- swarm "$@"
fi

# Look for Swarm subcommands.
if [ "$1" = 'manage' ] || [ "$1" = 'join'  ]; then
    shift
    set -- swarm $1 \
        $SWARM_ADVERTISE \
        "$@"
elif swarm --help "$1" 2>&1 | grep -q "swarm $1"; then
    set -- swarm "$@"
fi

exec "$@"
