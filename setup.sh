#!/bin/sh

username="$(whoami)"
userid="$(id -u)"
groupid="$(id -g)"
userpass="Password123!"

apt update
apt upgrade

mkdir -p ~/media/music
mkdir -p ~/media/video # mkdir -p ~/media/video/series-a/season00/s01E01.mkv & mkdir -p ~/media/video/movie-name/data like mp3 mkv etc
mkdir -p ~/media/books

mkdir -p ~/docker/jellyfin
curl -L https://raw.githubusercontent.com/florianthepro/jellyfin/main/docker/jellyfin/compose.yaml -o ~/docker/jellyfin/compose.yaml
sed -i "s|username|$username|g" ~/docker/jellyfin/compose.yaml
#mkdir -p ~/docker/sonarr
#curl -L https://raw.githubusercontent.com/florianthepro/jellyfin/main/docker/sonarr/compose.yaml -o ~/docker/sonarr/compose.yaml
#sed -i "s|username|$username|g" ~/docker/sonarr/compose.yaml
#mkdir -p ~/docker/radarr
#curl -L https://raw.githubusercontent.com/florianthepro/jellyfin/main/docker/radarr/compose.yaml -o ~/docker/radarr/compose.yaml
#sed -i "s|username|$username|g" ~/docker/radarr/compose.yaml
