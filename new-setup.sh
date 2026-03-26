#!/bin/sh
curl -sSL https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/cleanup.sh | sudo bash
clear
set -euo pipefail
cd /home/$(whoami)
sudo apt update -y
sudo apt upgrade -y

ask() {
printf "%s" "$1" >/dev/tty
IFS= read -r REPLY </dev/tty
}

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

clear
username="$(whoami)"
userid="$(id -u)"
groupid="$(id -g)"

clear
ask "Please enter your Password: "
userpass="$REPLY"

while :; do

clear
ask "language ('de' or 'en'):"
language="$REPLY"

#ui_culture_normalized=$(printf '%s' "$ui_culture" | tr 'A-Z' 'a-z')
case "$language" in
de|en)
break
;;
*)
;;
esac
done

case "$language" in
  de)
    ui_culture="de"
    display_language="de-de"
    country_code="DE"
    country_name="Germany"
    ;;
  en|*)
    ui_culture="en"
    display_language="en-us"
    country_code="US"
    country_name="United States"
    ;;
esac

clear
cat <<'END'
>goto "https://login.tailscale.com/admin/settings/keys"
>press "Generate auth key..."
END
ask "Enter your Auth Key: "
tsauthkey="$REPLY"

clear
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
clear
#===== setup =====

#===== setup =====
addr=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") {print $(i+1); exit}}')
clear
docker compose -f /home/$username/docker/compose.yaml up -d
echo "wait for jellyfin"
sleep 15
: <<'EEOF'
curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "{
    \"UICulture\": \"$ui_culture\",
    \"PreferredDisplayLanguage\": \"$display_language\",
    \"MetadataCountryCode\": \"$country_code\",
    \"MetadataCountryName\": \"$country_name\",
    \"ServerName\": \"jellyfin\"
  }" \
  "http://$addr:8096/Startup/Configuration"

curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "{
    \"Name\": \"$username\",
    \"Password\": \"$userpass\",
    \"PasswordConfirm\": \"$userpass\"
  }" \
  "http://$addr:8096/Startup/User"

curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "EnableRemoteAccess": true,
    "EnableAutomaticPortMapping": true
  }' \
  "http://$addr:8096/Startup/RemoteAccess"

curl -s -X POST "http://$addr:8096/Startup/Complete"
EEOF
clear
echo "http://$addr:8096/"
echo "$username"
echo "$userpass"

: <<'EOF'
tailscale funnel 8096 on
#===== end =====
clear
#cat ./docker/compose.yaml



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
EOF

