#!/bin/sh
set -euo pipefail

ask() {
printf "%s" "$1" >/dev/tty
IFS= read -r REPLY </dev/tty
}

sudo apt update
sudo apt upgrade

#===== intallation =====

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

printf "Please enter done: " >&2
IFS= read -r donener

curl -sSL https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/docker.sh | sudo bash
sudo usermod -aG docker "$(whoami)"
username="$(whoami)"
userid="$(id -u)"
groupid="$(id -g)"

ask "Please enter your Password: "
userpass="$REPLY"

echo "goto https://login.tailscale.com/admin/settings/keys"
echo "press Generate auth key..."

ask "Enter your Auth Key: "
tsauthkey="$REPLY"

mkdir -p ~/media/music
mkdir -p ~/media/video
mkdir -p ~/media/books
mkdir ~/docker
mkdir -p ~/docker/jellyfin
mkdir -p ~/docker/seerr
mkdir -p ~/docker/sonarr
mkdir -p ~/docker/radarr
mkdir -p ~/docker/qbittorrent
sudo curl -L https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/compose.yaml -o ~/docker/compose.yaml
sed -i "s/fill-usr/$username/g" ~/docker/compose.yaml
sed -i "s/fill-key/$tsauthkey/g" ~/docker/compose.yaml

#===== setup =====

docker compose -f /home/$username/docker/compose.yaml up -d
tailscale funnel 8096 on
