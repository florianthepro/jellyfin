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
END
ask "Enter your Auth Key: "
tsauthkey="$REPLY"
clear
cat <<'END'
>goto https://login.tailscale.com/admin/acls/file
>press "Edit anyway..."
>add:
====================
	"nodeAttrs": [
		{
			"target": ["autogroup:member"],
			"attr":   ["funnel"]
		}
	]
===================
END
ask "done? "

sudo mkdir -p ~/media/{music,video,books}
sudo mkdir -p ~/docker/{jellyfin,seerr,sonarr,radarr,qbittorrent}

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
docker compose -f /home/$username/docker/compose.yaml up -d
#docker funnel up     tailscale funnel 8096 on
#===== end ======
echo "wait for jellyfin"
sleep 15
clear
cat <<'END'
jellyfin:
http://$addr:8096/

jellyfin via tailscale:
http://$addr

seerr:
http://$addr:5055/

sonarr:
http://$addr:8989/

radarr:
http://$addr:7878/

qbittorrent:
echo "http://$addr:8080/
END
