#!/bin/sh

set -euo pipefail
cd /home/$(whoami)

sudo apt update -y
sudo apt upgrade -y

ask() {
printf "%s" "$1" >/dev/tty
IFS= read -r REPLY </dev/tty
}

addr=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") {print $(i+1); exit}}')
username="$(whoami)"
clear
cat <<'END'
>goto "https://login.tailscale.com/admin/settings/keys"
>press "Generate auth key..."
>press "Pre-approved"
>press "Generate Key"
END
ask "Enter your Auth Key: "
tsauthkey="$REPLY"
clear
cat <<'END'
>goto https://login.tailscale.com/admin/acls/file
>press "Edit anyway..."
>add:

	"nodeAttrs": [
		{
			"target": ["autogroup:member"],
			"attr":   ["funnel"]
		}
	]

END
ask "done? "

sudo mkdir -p ~/media/{music,video,books}
sudo mkdir -p ~/docker/{jellyfin,seerr,sonarr,radarr,qbittorrent}
sudo mkdir -p ~/docker/seerr/config
sudo curl -L https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/compose.yaml -o ~/docker/compose.yaml
sudo sed -i "s/fill-usr/$username/g" ~/docker/compose.yaml
sudo sed -i "s/fill-key/$tsauthkey/g" ~/docker/compose.yaml

#===== docker =====
sudo apt update -qq -y
sudo apt install -qq -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -qq -y
sudo apt install -qq -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$(whoami)"
sudo chown -R 1000:1000 ~/docker/seerr/config

clear
docker compose -f /home/$username/docker/compose.yaml up -d
sudo docker exec tailscale tailscale funnel -bg 8096
#===== end ======
echo "wait for jellyfin"
sleep 15
tcaddr=$(docker exec tailscale tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')
clear
echo "jellyfin via tailscale:"
echo "http://$tcaddr"
echo ""
echo "jellyfin:"
echo "http://$addr:8096/"
echo ""
echo "seerr:"
echo "http://$addr:5055/"
echo ""
echo "sonarr:"
echo "http://$addr:8989/"
echo ""
echo "radarr:"
echo "http://$addr:7878/"
echo ""
echo "qbittorrent:"
echo "http://$addr:8080/"
#EOF
