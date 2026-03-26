#!/bin/sh
apt update
apt upgrade
apt install unattended-upgrades
unattended-upgrade
mkdir -p ~/docker/jellyfin
mkdir -p ~/docker/sonarr
mkdir -p ~/docker/
