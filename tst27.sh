#!/bin/sh

set -euo pipefail
cd /home/$(whoami)

username="$(whoami)"

ask() {
printf "%s" "$1" >/dev/tty
IFS= read -r REPLY </dev/tty
}

DOCKER_GID=$(getent group docker | cut -d: -f3)
echo "$DOCKER_GID"
DOCKER_UID=$(getent passwd "$username" | cut -d: -f3)
echo "$DOCKER_UID"
DOCKER_GID=$(getent passwd "$username" | cut -d: -f4) 
echo "$DOCKER_GID"
#sudo chown -R "$DOCKER_UID:$DOCKER_GID" /home/$username/docker
#sudo chmod -R u+rwX /home/$username/docker
 
sudo chown -R $(id -u):$(id -g) ~/docker && sudo chmod -R u+rwX ~/docker
 
ask "done? "
