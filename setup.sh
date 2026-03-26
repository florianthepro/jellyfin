#!/bin/sh
apt update
apt upgrade
mkdir -p ~/docker/jellyfin
mkdir -p ~/docker/sonarr
mkdir -p ~/docker/radarr
curl -L https://raw.githubusercontent.com/florianthepro/jellyfin/main/docker/jellyfin/compose.yaml -o ~/docker/jellyfin/compose.yaml
curl -L https://raw.githubusercontent.com/florianthepro/jellyfin/main/docker/sonarr/compose.yaml -o ~/docker/sonarr/compose.yaml
curl -L https://raw.githubusercontent.com/florianthepro/jellyfin/main/docker/radarr/compose.yaml -o ~/docker/radarr/compose.yaml
