#!/bin/sh
#W.I.:P
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
userid="$(id -u)"
groupid="$(id -g)"
ui_culture="de"
display_language="de-de"
country_code="DE"
country_name="Germany"
userpass="Password123!"

clear
echo "http://$addr:8096/"
echo "$username"
echo "$userpass"

: <<'EOF'
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
