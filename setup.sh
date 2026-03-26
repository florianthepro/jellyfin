#!/bin/sh
#curl -sSL https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/setup.sh | bash
username="$(whoami)"
userid="$(id -u)"
groupid="$(id -g)"
userpass="Password123!"

#apt update
#apt upgrade

mkdir -p ~/media/music
mkdir -p ~/media/video #mkdir -p ~/media/video/series-a/season00/s01E01.mkv & mkdir -p ~/media/video/movie-name/data like mp3 mkv etc
mkdir -p ~/media/books
mkdir -p ~/docker
mkdir -p ~/docker/jellyfin
mkdir -p ~/docker/seerr
mkdir -p ~/docker/sonarr
mkdir -p ~/docker/radarr
mkdir -p ~/docker/qbittorrent
curl -L https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/compose.yaml -o ~/docker/compose.yaml
sed -i "s|username|$username|g" ~/docker/compose.yaml
