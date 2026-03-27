#!/bin/sh
# Unattended Jellyfin-Ersteinrichtung + Bibliotheken (POSIX /bin/sh)

# ==============================
# KONFIGURATION
# ==============================
JELLYFIN_URL="http://localhost:8096"

# Wizard: Sprache & Metadaten-Region
UI_CULTURE="de-DE"     # z. B. en-US, de-DE
META_LANG="de"         # ISO-639-1
META_COUNTRY="DE"      # ISO-3166-1 Alpha-2

# Admin-Benutzer
ADMIN_USER="admin"
ADMIN_PASSWORD="ChangeMe123!"

# Netzwerk
ENABLE_REMOTE_ACCESS="true"   # "true" | "false"
ENABLE_UPNP="false"           # "true" | "false"

# Bibliotheken: pro Zeile  Anzeigename|collectionType|pfad1(;pfad2;pfad3...)
# Gültige collectionType: movies, tvshows, music, books, photos, mixed
LIBRARIES="\
Filme|movies|/srv/media/filme
Serien|tvshows|/srv/media/serien
Musik|music|/srv/media/musik
"

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
  curl -sS -f "$@"
}

wait_for_ready() {
  log "Warte auf Jellyfin (${JELLYFIN_URL}) ..."
  i=0
  while : ; do
    code="$(curl -s -o /dev/null -w '%{http_code}' "${JELLYFIN_URL}/health" || true)"
    if [ "${code}" = "200" ]; then break; fi
    code="$(curl -s -o /dev/null -w '%{http_code}' "${JELLYFIN_URL}/System/Info/Public" || true)"
    if [ "${code}" = "200" ]; then break; fi
    i=$((i+1))
    [ $i -gt 120 ] && { log "Timeout beim Warten auf Jellyfin."; exit 1; }
    sleep 1
  done
  log "Jellyfin ist erreichbar."
}

complete_wizard_steps() {
  log "Setze Wizard-Basiskonfiguration ..."
  curl_silent -X POST \
    -H "${AUTH_HEADER}" -H "${JSON_CT}" \
    -d "{\"UICulture\":\"${UI_CULTURE}\",\"MetadataCountryCode\":\"${META_COUNTRY}\",\"PreferredMetadataLanguage\":\"${META_LANG}\"}" \
    "${JELLYFIN_URL}/Startup/Configuration" >/dev/null

  log "Erzeuge Admin-Benutzer ..."
  curl_silent -X POST \
    -H "${AUTH_HEADER}" -H "${JSON_CT}" \
    -d "{\"Name\":\"${ADMIN_USER}\",\"Password\":\"${ADMIN_PASSWORD}\"}" \
    "${JELLYFIN_URL}/Startup/User" >/dev/null

  log "Setze Remote-Access ..."
  curl_silent -X POST \
    -H "${AUTH_HEADER}" -H "${JSON_CT}" \
    -d "{\"EnableRemoteAccess\":${ENABLE_REMOTE_ACCESS},\"EnableAutomaticPortMapping\":${ENABLE_UPNP}}" \
    "${JELLYFIN_URL}/Startup/RemoteAccess" >/dev/null

  log "Schließe Wizard ..."
  curl_silent -X POST -H "${AUTH_HEADER}" "${JELLYFIN_URL}/Startup/Complete" >/dev/null
}

authenticate_and_get_token() {
  log "Authentifiziere als Admin, um API-Token zu erhalten ..."
  resp="$(curl_silent -X POST \
          -H "${AUTH_HEADER}" -H "${JSON_CT}" \
          -d "{\"Username\":\"${ADMIN_USER}\",\"Pw\":\"${ADMIN_PASSWORD}\"}" \
          "${JELLYFIN_URL}/Users/AuthenticateByName")"
  token="$(printf '%s' "${resp}" | sed -n 's/.*"AccessToken"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"
  [ -z "${token:-}" ] && { log "Konnte AccessToken nicht extrahieren! Antwort: ${resp}"; exit 1; }
  AUTH_HEADER="Authorization: MediaBrowser Client=\"${CLIENT_NAME}\", Device=\"${DEVICE_NAME}\", DeviceId=\"${DEVICE_ID}\", Version=\"${CLIENT_VERSION}\", Token=\"${token}\""
  log "Token erhalten."
}

create_libraries() {
  log "Erzeuge Bibliotheken und füge Pfade hinzu ..."
  printf '%s\n' "$LIBRARIES" | while IFS= read -r line; do
    # leere/kommentierte Zeilen überspringen
    [ -z "${line}" ] && continue
    case "$line" in \#*) continue ;; esac

    name=$(printf '%s' "$line" | cut -d'|' -f1)
    ctype=$(printf '%s' "$line" | cut -d'|' -f2)
    paths=$(printf '%s' "$line" | cut -d'|' -f3)

    [ -z "${name}" ] || [ -z "${ctype}" ] || [ -z "${paths}" ] && continue

    # 1) Virtuelles Verzeichnis anlegen (Query-Parameter, kein JSON-Body)
    curl_silent -X POST \
      -H "${AUTH_HEADER}" \
      "${JELLYFIN_URL}/Library/VirtualFolders?collectionType=$(printf '%s' "${ctype}" | sed 's/ /%20/g')&refreshLibrary=true&name=$(printf '%s' "${name}" | sed 's/ /%20/g')" >/dev/null

    # 2) Pfade hinzufügen
    OLD_IFS="$IFS"; IFS=';'
    for p in ${paths}; do
      [ -z "${p}" ] && continue
      curl_silent -X POST \
        -H "${AUTH_HEADER}" -H "${JSON_CT}" \
        -d "{\"Name\":\"${name}\",\"Path\":\"${p}\"}" \
        "${JELLYFIN_URL}/Library/VirtualFolders/Paths?refreshLibrary=true" >/dev/null
    done
    IFS="$OLD_IFS"

    log "Bibliothek \"${name}\" (${ctype}) eingerichtet."
  done
}

summary() {
  log "Fertig."
  log "Admin: ${ADMIN_USER}"
  log "UI-Sprache: ${UI_CULTURE}, Metadaten: ${META_LANG}-${META_COUNTRY}"
  log "Remote Access: ${ENABLE_REMOTE_ACCESS}, UPnP: ${ENABLE_UPNP}"
}

main() {
  wait_for_ready

  # Wizard bereits erledigt?
  if curl_silent "${JELLYFIN_URL}/System/Info/Public" | grep -q '"StartupWizardCompleted":true'; then
    log "Hinweis: Wizard ist bereits abgeschlossen – setze trotzdem Bibliotheken (falls konfiguriert)."
  else
    complete_wizard_steps
  fi

  authenticate_and_get_token
  create_libraries
  summary
}

main "$@"
