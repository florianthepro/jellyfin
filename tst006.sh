#!/bin/sh
set -euo pipefail
ask() {
printf "%s" "$1" >/dev/tty
IFS= read -r REPLY </dev/tty
}
sudo rm -rf *
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
sudo apt update -y
sudo apt upgrade -y
#===== intallation =====
clear
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
ask "done? "
username="$(whoami)"
userid="$(id -u)"
groupid="$(id -g)"
clear
ask "Please enter your Password: "
userpass="$REPLY"
clear
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
ask "done2? "
sudo curl -L https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/compose.yaml -o ~/docker/compose.yaml
ask "done3? "
sed -i "s/fill-usr/$username/g" ~/docker/compose.yaml
sed -i "s/fill-key/$tsauthkey/g" ~/docker/compose.yaml
#===== docker =====
sudo apt update -qq -y
sudo apt install -qq -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -qq -y
sudo apt install -qq -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$(whoami)"
#===== setup =====
docker compose -f /home/$username/docker/compose.yaml up -d
tailscale funnel 8096 on
