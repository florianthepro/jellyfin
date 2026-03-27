#!/usr/bin/env bash

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
jellyfin_name="jellyfin"
jellyfin_url="http://$addr:8096"
jellyfin_language="de-DE"
jellyfin_metadata_language="de"
jellyfin_metadata_country="DE"
jellyfin_admin_user="$username"
ask "Password: "
jellyfin_admin_password="$REPLY"
jellyfin_remote_access="true"
jellyfin_remote_upnp="false"

echo "Warte auf Jellyfin‑Wizard..."
until curl -fsS "http://127.0.0.1:8096/System/Info/Public" >/dev/null 2>&1; do
  sleep 1
done

curl -fsS -X POST "$jellyfin_url/Startup/Configuration" \
-H "Content-Type: application/json" \
-d "{\"MetadataCountryCode\":\"$jellyfin_metadata_country\",\"PreferredMetadataLanguage\":\"$jellyfin_metadata_language\",\"UICulture\":\"$jellyfin_language\"}" \
>/dev/null

curl -fsS -X POST "$jellyfin_url/Startup/User" \
-H "Content-Type: application/json" \
-d "{\"Name\":\"$jellyfin_admin_user\",\"Password\":\"$jellyfin_admin_password\"}" \
>/dev/null

curl -fsS -X POST "$jellyfin_url/Startup/RemoteAccess" \
-H "Content-Type: application/json" \
-d "{\"EnableRemoteAccess\":$jellyfin_remote_access,\"EnableAutomaticPortMapping\":$jellyfin_remote_upnp}" \
>/dev/null

curl -fsS -X POST "$jellyfin_url/Startup/Complete" >/dev/null
