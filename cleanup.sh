#!/usr/bin/env bash
set -euo pipefail
clear
aggressive=false
user_data=false
while [ $# -gt 0 ]; do
case "$1" in
  --aggressive)
    aggressive=true
    shift
  ;;
  --user-data)
    user_data=true
    shift
  ;;
  *)
    echo "Unbekannte Option: $1"
    echo "Verwendung: $0 [--aggressive] [--user-data]"
    exit 1
  ;;
esac
done
if [ "$(id -u)" -ne 0 ]; then
  echo "Bitte mit sudo oder als root ausführen."
  exit 1
fi
echo "===== Docker Cleanup Start ====="
if command -v docker >/dev/null 2>&1; then
  echo "Stoppe laufende Container..."
  docker ps -q | xargs -r docker stop
  echo "Entferne alle Container..."
  docker ps -aq | xargs -r docker rm
  echo "Entferne alle Images..."
  docker images -q | xargs -r docker rmi
  if [ "$aggressive" = true ]; then
    echo "Entferne alle Volumes..."
    docker volume ls -q | xargs -r docker volume rm
    echo "Entferne alle benutzerdefinierten Netzwerke..."
    docker network ls --filter "type=custom" -q | xargs -r docker network rm
  else
    echo "Volumes/Netzwerke bleiben erhalten (verwende --aggressive für komplettes Entfernen)."
  fi
else
  echo "docker Befehl nicht gefunden, überspringe Container/Image/Volume/Netzwerk-Cleanup."
fi
echo "Entferne Docker-Pakete (apt)..."
apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker.io docker-doc docker-compose podman-docker containerd runc || true
apt-get autoremove -y
apt-get autoclean
echo "Entferne Docker-Datenverzeichnisse..."
rm -rf /var/lib/docker
rm -rf /var/lib/containerd
if [ "$user_data" = true ]; then
  echo "Entferne Benutzer-Testverzeichnisse im Home (~docker, ~media)..."
  if [ -n "${SUDO_USER-}" ]; then
    user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
  else
    user_home="$HOME"
  fi
  if [ -n "$user_home" ] && [ "$user_home" != "/" ]; then
    rm -rf "$user_home/docker"
    rm -rf "$user_home/media"
  else
    echo "Konnte Home-Verzeichnis nicht sicher ermitteln, lasse Benutzer-Verzeichnisse unverändert."
  fi
else
  echo "Benutzer-Verzeichnisse (~docker, ~media) bleiben erhalten (verwende --user-data für Entfernen)."
fi
echo "===== Docker Cleanup fertig ====="
