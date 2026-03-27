#!/usr/bin/env bash
set -euo pipefail
addr=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") {print $(i+1); exit}}')
port="8096"
serverName="Jellyfin"
adminName="admin"
adminPassword="Password123!"
curl -fsS -X POST "http://$addr:$port/Startup/Configuration" -H "Content-Type: application/json" -d "{\"ServerName\":\"$serverName\",\"MetadataCountryCode\":\"DE\",\"PreferredMetadataLanguage\":\"de\",\"UICulture\":\"de-DE\"}"
curl -fsS -X POST "http://$addr:$port/Startup/User" -H "Content-Type: application/json" -d "{\"Name\":\"$adminName\",\"Password\":\"$adminPassword\"}"
curl -fsS -X POST "http://$addr:$port/Startup/RemoteAccess" -H "Content-Type: application/json" -d '{"EnableRemoteAccess":true,"EnableAutomaticPortMapping":false}'
curl -fsS -X POST "http://$addr:$port/Startup/Complete" -H "Content-Type: application/json" -d '{}'
