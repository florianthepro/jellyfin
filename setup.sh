#!/bin/sh

username="$(whoami)"
userid="$(id -u)"
groupid="$(id -g)"
userpass="Password123!"

apt update
apt upgrade
mkdir -p ~/media/music
mkdir -p ~/media/video
mkdir -p ~/media/books
# mkdir -p ~/media/video/series-a/season00/s01E01.mkv
# mkdir -p ~/media/video/movie-name/data like mp3 mkv etc
mkdir -p ~/docker/jellyfin
mkdir -p ~/docker/sonarr
mkdir -p ~/docker/radarr
curl -L https://raw.githubusercontent.com/florianthepro/jellyfin/main/docker/jellyfin/compose.yaml -o ~/docker/jellyfin/compose.yaml
curl -L https://raw.githubusercontent.com/florianthepro/jellyfin/main/docker/sonarr/compose.yaml -o ~/docker/sonarr/compose.yaml
curl -L https://raw.githubusercontent.com/florianthepro/jellyfin/main/docker/radarr/compose.yaml -o ~/docker/radarr/compose.yaml
