#!/bin/sh
# Unattended Jellyfin-Ersteinrichtung + Bibliotheken per HTTP-API
# Getestet als reines /bin/sh (dash-kompatibel)

# ==============================
# KONFIGURATION (VALIDE BEISPIELE)
# ==============================
JELLYFIN_URL="http://localhost:8096"

# Wizard: Sprache & Metadaten-Region
UI_CULTURE="de-DE"            # UI-Sprache (z. B. en-US, de-DE)
META_LANG="de"                # Bevorzugte Metadaten-Sprache (ISO-639-1)
META_COUNTRY="DE"             # Metadaten-Land (ISO-3166-1 Alpha-2)

# Admin-Benutzer
ADMIN_USER="admin"
ADMIN_PASSWORD="ChangeMe123!"

# Netzwerk / Remote Access
ENABLE_REMOTE_ACCESS="true"   # "true" | "false"
ENABLE_UPNP="false"           # "true" | "false" (automatische Port-Mappings/UPnP)

# Medienbibliotheken:
# Format pro Zeile: Anzeigename|collectionType|pfad1(;pfad2;pfad3...)
# Gültige collectionType-Beispiele: movies, tvshows, music, books, photos, mixed
LIBRARIES=$(cat <<'EOF'
Filme|movies|/srv/media/filme
Serien|tvshows|/srv/media/serien
Musik|music|/srv/media/musik
EOF
)

# ==============================
# AB HIER NICHT MEHR ÄNDERN
# ==============================
set -eu

CLIENT_NAME="jf-setup-script"
DEVICE_NAME="$(hostname 2>/dev/null || echo setup-host)"
DEVICE_ID="setup-$(date +%s)"
CLIENT_VERSION="1.0.0"

AUTH_HEADER="Authorization: MediaBrowser Client=\"${CLIENT_NAME}\", Device=\"${DEVICE_NAME}\", DeviceId=\"${DEVICE_ID}\", Version=\"${CLIENT_VERSION}\""
JSON_CT="Content-Type: application/json"

log() { printf '%s\n' "$*" >&2; }

curl_silent() {
  # $1... args to curl
  curl -sS -f "$@"
}

wait_for_ready() {
  log "Warte auf Jellyfin (${JELLYFIN_URL}) ..."
  i=0
  # Bevorzugt /health (200 = ok), sonst /System/Info/Public (200 = ok)
  while : ; do
    if curl -s -o /dev/null -w '%{http_code}' "${JELLYFIN_URL}/health" 2>/dev/null | grep -q '^200$'; then
      break
    fi
    if curl -s -o /dev/null -w '%{http_code}' "${JELLYFIN_URL}/System/Info/Public" 2>/dev/null | grep -q '^200$'; then
      break
    fi
    i=$((i+1))
    if [ $i -gt 120 ]; then
      log "Zeitüberschreitung beim Warten auf Jellyfin."
      exit 1
    fi
    sleep 1
  done
  log "Jellyfin ist erreichbar."
}

complete_wizard_steps() {
  log "Setze Wizard-Basiskonfiguration ..."
  # POST /Startup/Configuration
  curl_silent -X POST \
    -H "${AUTH_HEADER}" -H "${JSON_CT}" \
    -d "{\"UICulture\":\"${UI_CULTURE}\",\"MetadataCountryCode\":\"${META_COUNTRY}\",\"PreferredMetadataLanguage\":\"${META_LANG}\"}" \
    "${JELLYFIN_URL}/Startup/Configuration" >/dev/null

  log "Erzeuge Admin-Benutzer ..."
  # POST /Startup/User
  curl_silent -X POST \
    -H "${AUTH_HEADER}" -H "${JSON_CT}" \
    -d "{\"Name\":\"${ADMIN_USER}\",\"Password\":\"${ADMIN_PASSWORD}\"}" \
    "${JELLYFIN_URL}/Startup/User" >/dev/null

  log "Setze Remote-Access ..."
  # POST /Startup/RemoteAccess
  curl_silent -X POST \
    -H "${AUTH_HEADER}" -H "${JSON_CT}" \
    -d "{\"EnableRemoteAccess\":${ENABLE_REMOTE_ACCESS},\"EnableAutomaticPortMapping\":${ENABLE_UPNP}}" \
    "${JELLYFIN_URL}/Startup/RemoteAccess" >/dev/null

  log "Schließe Wizard ..."
  # POST /Startup/Complete
  curl_silent -X POST -H "${AUTH_HEADER}" "${JELLYFIN_URL}/Startup/Complete" >/dev/null
}

authenticate_and_get_token() {
  log "Authentifiziere als Admin, um API-Token zu erhalten ..."
  # POST /Users/AuthenticateByName (JSON: {"Username": "...", "Pw": "..."})
  resp="$(curl_silent -X POST \
          -H "${AUTH_HEADER}" -H "${JSON_CT}" \
          -d "{\"Username\":\"${ADMIN_USER}\",\"Pw\":\"${ADMIN_PASSWORD}\"}" \
          "${JELLYFIN_URL}/Users/AuthenticateByName")"
  # Primitive Token-Extraktion ohne jq
  token="$(printf '%s' "${resp}" | sed -n 's/.*"AccessToken"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
  if [ -z "${token:-}" ]; then
    log "Konnte AccessToken nicht aus Antwort extrahieren!"
    log "Antwort war: ${resp}"
