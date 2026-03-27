#!/bin/sh

set -euo pipefail
cd /home/$(whoami)

username="$(whoami)"

DOCKER_GID=$(getent group docker | cut -d: -f3) | bash -x
echo "$DOCKER_GID" | bash -x
DOCKER_UID=$(getent passwd "$username" | cut -d: -f3) | bash -x
echo "$DOCKER_UID" | bash -x
DOCKER_GID=$(getent passwd "$username" | cut -d: -f4) | bash -x
echo "$DOCKER_GID" | bash -x
#sudo chown -R "$DOCKER_UID:$DOCKER_GID" /home/$username/docker
#sudo chmod -R u+rwX /home/$username/docker
 
sudo chown -R $(id -u):$(id -g) ~/docker && sudo chmod -R u+rwX ~/docker | bash -x
 
ask "done? "
