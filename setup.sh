#===== setup =====
addr=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") {print $(i+1); exit}}')
docker compose -f /home/$username/docker/compose.yaml up -d
clear
echo "wait for jellyfin"
sleep 15
clear

ask "ui-culture (like 'de' or 'en'):"
ui-culture="$REPLY"

case "$ui_culture_normalized" in
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

curl -s -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "UICulture": "$ui-culture",
    "PreferredDisplayLanguage": "$display-language",
    "MetadataCountryCode": "country-code",
    "MetadataCountryName": "Germany",
    "ServerName": "jellyfin"
  }' \
  "http://$addr:8096/Startup/Configuration"

curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "{
    \"Name\": \"root\",
    \"Password\": \"DEIN_PASSWORT\",
    \"PasswordConfirm\": \"DEIN_PASSWORT\"
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






#tailscale funnel 8096 on
#===== end =====
clear
cat ./docker/compose.yaml
ask "done? "


ziel:
5. jellyfin auto-setup:
   erster user: admin / Password123!
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
