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

mkdir -p ~/docker/jellyfin-enhanced-setup
curl -L https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/docker/jellyfin-enhanced-setup/compose.yaml -o ~/docker/jellyfin-enhanced-setup/compose.yaml
sed -i "s|username|$username|g" ~/docker/jellyfin-enhanced-setup/compose.yaml

#mkdir -p ~/docker/sonarr
#curl -L https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/docker/sonarr/compose.yaml -o ~/docker/sonarr/compose.yaml
#sed -i "s|username|$username|g" ~/docker/sonarr/compose.yaml

#mkdir -p ~/docker/radarr
#curl -L https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/docker/radarr/compose.yaml -o ~/docker/radarr/compose.yaml
#sed -i "s|username|$username|g" ~/docker/radarr/compose.yaml

#mkdir -p ~/docker/qbittorrent
#curl -L https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/docker/qbittorrent/compose.yaml -o ~/docker/qbittorrent/compose.yaml
#sed -i "s|username|$username|g" ~/docker/qbittorrent/compose.yaml
