#!/usr/bin/env bash

set -euo pipefail
cd /home/$(whoami)

ask() {
printf "%s" "$1" >/dev/tty
IFS= read -r REPLY </dev/tty
}

username="$(whoami)"
ask "Enter your Admin Password: "
userpass="$REPLY"

sudo curl -fsS -X POST "http://127.0.0.1:8096/Startup/Configuration" -H "Content-Type: application/json" -d '{"MetadataCountryCode":"DE","PreferredMetadataLanguage":"de","UICulture":"de-DE"}'
sudo curl -fsS -X POST "http://127.0.0.1:8096/Startup/User" -H "Content-Type: application/json" -d "{\"Name\":\"$username\",\"Password\":\"$userpass\"}"
sudo curl -fsS -X POST "http://127.0.0.1:8096/Startup/RemoteAccess" -H "Content-Type: application/json" -d '{"EnableRemoteAccess":true,"EnableAutomaticPortMapping":false}'
sudo curl -fsS -X POST "http://127.0.0.1:8096/Startup/Complete" -H "Content-Type: application/json" -d '{}'
