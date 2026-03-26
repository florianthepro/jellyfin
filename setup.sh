#!/bin/sh
apt update -y -qq
apt upgrade -y -qq
mkdir -p ~/docker/jellyfin
mkdir -p ~/docker/sonarr
mkdir -p ~/docker/radarr
