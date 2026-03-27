#!/usr/bin/env bash

set -euo pipefail
cd /home/$(whoami)

ask() {
printf "%s" "$1" >/dev/tty
IFS= read -r REPLY </dev/tty
}

addr=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") {print $(i+1); exit}}')
sleep 1
echo $addr
curl -fsS -X POST "http://$addr:8096/Startup/Configuration" -H "Content-Type: application/json" -d '{"MetadataCountryCode":"DE","PreferredMetadataLanguage":"de","UICulture":"de-DE"}'
curl -fsS -X POST "http://$addr:8096/Startup/User" -H "Content-Type: application/json" -d "{\"Name\":\"admin\",\"Password\":\"Password123!\"}"
curl -fsS -X POST "http://$addr:8096/Startup/RemoteAccess" -H "Content-Type: application/json" -d '{"EnableRemoteAccess":true,"EnableAutomaticPortMapping":false}'
curl -fsS -X POST "http://$addr:8096/Startup/Complete" -H "Content-Type: application/json" -d '{}'
