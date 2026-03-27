#!/usr/bin/env bash
set -euo pipefail
addr="10.100.66.34"
port="8096"
serverName="Jellyfin"
adminName="admin"
adminPassword="ChangeThisPassword123!"
systemInfo="$(curl -sS "http://$addr:$port/System/Info" || true)"
if [ -z "$systemInfo" ]; then
echo "Jellyfin nicht erreichbar auf http://$addr:$port"
exit 1
fi
if printf '%s' "$systemInfo" | grep -q '"StartupWizardCompleted":true'; then
echo "Startup-Wizard ist bereits abgeschlossen. Skript wird nicht ausgeführt."
exit 0
fi
curl -fsS -X POST "http://$addr:$port/Startup/Configuration" -H "Content-Type: application/json" -d "{\"ServerName\":\"$serverName\",\"MetadataCountryCode\":\"DE\",\"PreferredMetadataLanguage\":\"de\",\"UICulture\":\"de-DE\"}"
curl -fsS -X POST "http://$addr:$port/Startup/User" -H "Content-Type: application/json" -d "{\"Name\":\"$adminName\",\"Password\":\"$adminPassword\"}"
curl -fsS -X POST "http://$addr:$port/Startup/RemoteAccess" -H "Content-Type: application/json" -d '{"EnableRemoteAccess":true,"EnableAutomaticPortMapping":false}'
curl -fsS -X POST "http://$addr:$port/Startup/Complete" -H "Content-Type: application/json" -d '{}'
echo "Jellyfin-Erstkonfiguration abgeschlossen."
