#!/bin/sh
#curl -sSL https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/setup.sh | sudo bash
set -euo pipefail
username="$(whoami)"
userid="$(id -u)"
groupid="$(id -g)"
echo enter user password
userpass="Password123!"
echo enter tailsclae key get from https://login.tailscale.com/admin/settings/keys Auth keys
tsauthkey="key"
go to 
https://login.tailscale.com/admin/acls/file
"""""
add
	"nodeAttrs": [
		{
			"target": ["autogroup:member"],
			"attr":   ["funnel"]
		}
	]
  """""
apt update
apt upgrade
mkdir -p ~/media/music
mkdir -p ~/media/video
#mkdir -p ~/media/video/series-a/season00/s01E01.mkv & mkdir -p ~/media/video/movie-name/data like mp3 mkv etc
mkdir -p ~/media/books
mkdir -p ~/docker
mkdir -p ~/docker/jellyfin
mkdir -p ~/docker/seerr
mkdir -p ~/docker/sonarr
mkdir -p ~/docker/radarr
mkdir -p ~/docker/qbittorrent
curl -L https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/compose.yaml -o ~/docker/compose.yaml
sed -i "s|fill-usr|$username|g" ~/docker/compose.yaml
sed -i "s|fill-key|$tsauthkey|g" ~/docker/compose.yaml
docker install
compose up
#sudo tailscale funnel 8096 on
#sudo tailscale funnel on 8096
