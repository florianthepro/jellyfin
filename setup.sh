#!/bin/sh
#set -euo pipefail

sudo apt update
sudo apt upgrade

#===== intallation =====

ask_yes_no() {
while :; do
printf "%s [y/n]: " "$1" >&2
IFS= read -r answer
case "$answer" in
y|Y) return 0 ;;
n|N) return 1 ;;
*) printf "Bitte y

echo "goto https://login.tailscale.com/admin/acls/file"
echo "press Edit anyway..."
echo "add"
cat <<'END'
	"nodeAttrs": [
		{
			"target": ["autogroup:member"],
			"attr":   ["funnel"]
		}
	]
END

printf "done?" >&2
IFS= read -r _

curl -sSL https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/docker.sh | sudo bash

sudo usermod -aG docker "$(whoami)"

username="$(whoami)"
userid="$(id -u)"
groupid="$(id -g)"
#echo "Hello, World!"
userpass="$(prompt 'Please enter your Password: ')"
echo "goto https://login.tailscale.com/admin/settings/keys"
echo "press Generate auth key..."
tsauthkey="$(prompt 'Enter your Auth Key: ')"

mkdir -p ~/media/music
mkdir -p ~/media/video
mkdir -p ~/media/books
mkdir ~/docker
mkdir -p ~/docker/jellyfin
mkdir -p ~/docker/seerr
mkdir -p ~/docker/sonarr
mkdir -p ~/docker/radarr
mkdir -p ~/docker/qbittorrent
curl -L https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/compose.yaml -o ~/docker/compose.yaml
sed -i "s|fill-usr|$username|g" ~/docker/compose.yaml
sed -i "s|fill-key|$tsauthkey|g" ~/docker/compose.yaml

#===== setup =====
docker compose -f /home/$username/docker/compose.yaml up -d
tailscale funnel 8096 on
