#!/usr/bin/env bash
set -euo pipefail
addr="10.100.66.34"
port="8096"
serverName="Jellyfin"
adminName="admin"
adminPassword="Password123!"
curl -fsS -X POST "http://$addr:$port/Startup/Configuration" -H "Content-Type: application/json" -d "{\"ServerName\":\"$serverName\",\"MetadataCountryCode\":\"DE\",\"PreferredMetadataLanguage\":\"de\",\"UICulture\":\"de-DE\"}"
curl -fsS -X POST "http://$addr:$port/Startup/User" -H "Content-Type: application/json" -d "{\"Name\":\"$adminName\",\"Password\":\"$adminPassword\"}"
curl -fsS -X POST "http://$addr:$port/Startup/RemoteAccess" -H "Content-Type: application/json" -d '{"EnableRemoteAccess":true,"EnableAutomaticPortMapping":false}'
curl -fsS -X POST "http://$addr:$port/Startup/Complete" -H "Content-Type: application/json" -d '{}'
