#!/bin/sh
#set
set -euo pipefail
cd /home/$(whoami)

ask() {
printf "%s" "$1" >/dev/tty
IFS= read -r REPLY </dev/tty
}

name=$(hostname)
addr=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") {print $(i+1); exit}}')
username="$(whoami)"

clear

echo "go to https://login.tailscale.com/admin/settings/keys"
echo ">press Generate auth key...     >press Pre-approved      >press Generate Key"

ask "Enter your Auth Key: "
tsauthkey="$REPLY"

sudo apt update -y
sudo apt upgrade -y

sudo mkdir -p ~/media/{music,video,books}
sudo mkdir -p ~/docker/{jellyfin,seerr,sonarr,radarr,qbittorrent}
sudo mkdir -p ~/docker/seerr/config

sudo curl -L https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/compose.yaml -o ~/docker/compose.yaml

sudo sed -i "s/fill-usr/$username/g" ~/docker/compose.yaml
sudo sed -i "s/fill-key/$tsauthkey/g" ~/docker/compose.yaml
sudo sed -i "s/fill-hostname/$name/g" ~/docker/compose.yaml

#===== docker =====
sudo apt update -qq -y
sudo apt install -qq -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -qq -y
sudo apt install -qq -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$username"
sudo chown -R 1000:1000 /home/$username/docker/seerr/config

clear

docker compose -f /home/$username/docker/compose.yaml up -d

echo ""
sleep 15

sudo docker exec tailscale tailscale funnel --bg 8091 http 127.0.0.1:8091
sudo docker exec tailscale tailscale funnel -bg 8096 # test it

tcaddr=$(docker exec tailscale tailscale status --json | jq -r '.Self.DNSName' | sed 's/\.$//')

echo ""
sleep 5

echo "go to https://$tcaddr"
echo "complete setup wizard"
ask "done?"

clear

echo "go to https://$tcaddr"
echo ">login     >user icon      >admin dashbourd     >press Left Side API-Keys     >create and copy key"

ask "Enter your API Key: "
jfapi="$REPLY"



: <<'WIP'
: <<'LINKS'
jellyfin via tailscale: https://$tcaddr
jellyfin: http://$addr:8096/
seerr: http://$addr:5055/
sonarr: http://$addr:8989/
radarr: http://$addr:7878/
qbittorrent: http://$addr:8080/
filebrowser: http://$addr:8091/
LINKS
#=======================================================
clear
echo "http://$addr:8096/"
echo "$username"
echo "$userpass"

ziel:
   bibliothek "Serien" → /home/jellyfin/series
6. seerr installieren (seerr-compose.yaml aus repo)
   auto-setup admin / Password123!
7. jellyfin plugin "Enhancer" installieren:
   offizielles repo eintragen + plugin installieren + jellyfin reboot
8. sonarr + radarr installieren (compose-dateien aus repo)
   auto-setup admin / Password123!
9. integration:
   - sonarr API key → seerr
   - radarr API key → seerr
   - qbittorrent API key → sonarr + radarr
10. qbittorrent installieren:
    auto-setup admin / Password123!
11. sicherstellen:
    alle nutzen /home/jellyfin/series korrekt:
      - jellyfin: read
      - sonarr/radarr/qbit: write
12. cleanup:
    default admins entfernen
    default api keys entfernen
13. jellyfin bibliothek prüfen
14. sonarr/radarr/seerr/qbit verbindungen prüfen
15. configuration sauber setzen (basisoptionen)
16. css laden
WIP
