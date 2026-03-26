#!/bin/sh
set -euo pipefail

prompt() {
  local input=""
  while true; do
    printf "%s" "$1"
    read -r input
    [ -n "$input" ] && echo "$input" && return 0
    printf "Eingabe darf nicht leer sein. Bitte erneut versuchen.\n" >&2
  done
}

username="$(whoami)"
userid="$(id -u)"
groupid="$(id -g)"
#echo "Hello, World!"
userpass="$(prompt "Please enter your Password: ")"
echo "goto https://login.tailscale.com/admin/settings/keys"
echo "press Generate auth key..."
tsauthkey="$(prompt "enter your Auth Key: ")"

apt update
apt upgrade
mkdir -p ~/media/music
mkdir -p ~/media/video
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
