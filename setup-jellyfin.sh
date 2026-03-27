#!/usr/bin/env bash

set -euo pipefail
cd /home/$(whoami)

ask() {
printf "%s" "$1" >/dev/tty
IFS= read -r REPLY </dev/tty
}

addr=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") {print $(i+1); exit}}')
username="$(whoami)"
curl -fsS -X POST "http://127.0.0.1:8096/Startup/Configuration" -H "Content-Type: application/json" -d '{"MetadataCountryCode":"DE","PreferredMetadataLanguage":"de","UICulture":"de-DE"}'
curl -fsS -X POST "http://127.0.0.1:8096/Startup/User" -H "Content-Type: application/json" -d "{\"Name\":\"$username\",\"Password\":\"$userpass\"}"
curl -fsS -X POST "http://127.0.0.1:8096/Startup/RemoteAccess" -H "Content-Type: application/json" -d '{"EnableRemoteAccess":true,"EnableAutomaticPortMapping":false}'
curl -fsS -X POST "http://127.0.0.1:8096/Startup/Complete" -H "Content-Type: application/json" -d '{}'
