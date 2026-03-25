#!/bin/sh
set -e

TARGET_USER="jellyfin-admin"
TZ_DEFAULT="Europe/Berlin"
LANGUAGE_DEFAULT="de-DE"
JELLYFIN_PORT="8096"
SEERR_PORT="5055"
SONARR_PORT="8989"
RADARR_PORT="7878"
QBIT_WEBUI_PORT="8080"
QBIT_TORRENT_PORT="6881"

if [ "$(id -u)" -ne 0 ]; then
  echo "Starte Script mit Root-Rechten über sudo..."
  exec sudo "$0" "$@"
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "Benutzer '$TARGET_USER' existiert nicht. Bitte zuerst anlegen."
  exit 1
fi

HOME_DIR="/home/$TARGET_USER"
USER_UID="$(id -u "$TARGET_USER")"
USER_GID="$(id -g "$TARGET_USER")"

DOCKER_DIR="$HOME_DIR/docker"

JELLYFIN_BASE="$DOCKER_DIR/jellyfin"
JELLYFIN_CONFIG_DIR="$JELLYFIN_BASE/config"
JELLYFIN_CACHE_DIR="$JELLYFIN_BASE/cache"
JELLYFIN_SERIES_DIR="$JELLYFIN_BASE/series"
JELLYFIN_MOVIES_DIR="$JELLYFIN_BASE/movies"

SEERR_CONFIG_DIR="$DOCKER_DIR/seerr/config"
SONARR_CONFIG_DIR="$DOCKER_DIR/sonarr/config"
RADARR_CONFIG_DIR="$DOCKER_DIR/radarr/config"
QBIT_CONFIG_DIR="$DOCKER_DIR/qbittorrent/config"

DOWNLOADS_DIR="$DOCKER_DIR/downloads"

mkdir -p \
  "$DOCKER_DIR" \
  "$JELLYFIN_CONFIG_DIR" "$JELLYFIN_CACHE_DIR" "$JELLYFIN_SERIES_DIR" "$JELLYFIN_MOVIES_DIR" \
  "$SEERR_CONFIG_DIR" "$SONARR_CONFIG_DIR" "$RADARR_CONFIG_DIR" "$QBIT_CONFIG_DIR" \
  "$DOWNLOADS_DIR"

chown -R "$TARGET_USER:$TARGET_USER" "$DOCKER_DIR"

cat >"$JELLYFIN_CONFIG_DIR/branding.xml" <<'EOF'
<BrandingOptions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <LoginDisclaimer />
  <CustomCss>@import url('https://cdn.jsdelivr.net/gh/florianthepro/jellyfin@main/shared/jellyfin.css');</CustomCss>
  <SplashscreenEnabled>false</SplashscreenEnabled>
</BrandingOptions>
EOF
chown "$TARGET_USER:$TARGET_USER" "$JELLYFIN_CONFIG_DIR/branding.xml"

apt-get update
apt-get upgrade -y
apt-get install -y ca-certificates curl gnupg lsb-release wget

if [ ! -d /etc/apt/keyrings ]; then
  install -m 0755 -d /etc/apt/keyrings
fi

if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
fi

. /etc/os-release
CODENAME="$VERSION_CODENAME"
ARCH="$(dpkg --print-architecture)"
DOCKER_LIST="/etc/apt/sources.list.d/docker.list"

if [ ! -f "$DOCKER_LIST" ]; then
  echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable" >"$DOCKER_LIST"
fi

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker.service
systemctl enable --now containerd.service

if ! getent group docker >/dev/null 2>&1; then
  groupadd docker
fi
if ! id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx docker; then
  usermod -aG docker "$TARGET_USER"
fi

SERVER_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
if [ -z "$SERVER_IP" ]; then
  SERVER_IP="$(ip -4 addr show scope global 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)"
fi
if [ -z "$SERVER_IP" ]; then
  SERVER_IP="127.0.0.1"
fi
############################################################
# 2/3 — Docker Compose Dateien nativ erzeugen
############################################################

cat >"$DOCKER_DIR/jellyfin-compose.yaml" <<EOF
services:
  jellyfin:
    image: jellyfin/jellyfin
    container_name: jellyfin
    user: "${USER_UID}:${USER_GID}"
    ports:
      - "${JELLYFIN_PORT}:8096/tcp"
      - "7359:7359/udp"
    volumes:
      - ${JELLYFIN_CONFIG_DIR}:/config
      - ${JELLYFIN_CACHE_DIR}:/cache
      - ${JELLYFIN_SERIES_DIR}:/media
      - ${JELLYFIN_MOVIES_DIR}:/movies
    restart: unless-stopped
    environment:
      - TZ=${TZ_DEFAULT}
      - JELLYFIN_PublishedServerUrl=http://${SERVER_IP}:${JELLYFIN_PORT}
    extra_hosts:
      - "host.docker.internal:host-gateway"
EOF

cat >"$DOCKER_DIR/seerr-compose.yaml" <<EOF
services:
  seerr:
    image: ghcr.io/seerr-team/seerr:latest
    container_name: seerr
    init: true
    environment:
      - LOG_LEVEL=debug
      - TZ=${TZ_DEFAULT}
      - PORT=${SEERR_PORT}
    volumes:
      - ${SEERR_CONFIG_DIR}:/app/config
    ports:
      - "${SEERR_PORT}:5055"
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:5055/api/v1/status"]
      start_period: 20s
      timeout: 3s
      interval: 15s
      retries: 3
    restart: unless-stopped
EOF

cat >"$DOCKER_DIR/sonarr-compose.yaml" <<EOF
services:
  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    environment:
      - PUID=${USER_UID}
      - PGID=${USER_GID}
      - TZ=${TZ_DEFAULT}
    volumes:
      - ${SONARR_CONFIG_DIR}:/config
      - ${JELLYFIN_SERIES_DIR}:/tv
      - ${DOWNLOADS_DIR}:/downloads
    ports:
      - "${SONARR_PORT}:8989"
    restart: unless-stopped
EOF

cat >"$DOCKER_DIR/radarr-compose.yaml" <<EOF
services:
  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    environment:
      - PUID=${USER_UID}
      - PGID=${USER_GID}
      - TZ=${TZ_DEFAULT}
    volumes:
      - ${RADARR_CONFIG_DIR}:/config
      - ${JELLYFIN_MOVIES_DIR}:/movies
      - ${DOWNLOADS_DIR}:/downloads
    ports:
      - "${RADARR_PORT}:7878"
    restart: unless-stopped
EOF

cat >"$DOCKER_DIR/qbittorrent-compose.yaml" <<EOF
services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=${USER_UID}
      - PGID=${USER_GID}
      - TZ=${TZ_DEFAULT}
      - WEBUI_PORT=${QBIT_WEBUI_PORT}
      - TORRENTING_PORT=${QBIT_TORRENT_PORT}
    volumes:
      - ${QBIT_CONFIG_DIR}:/config
      - ${DOWNLOADS_DIR}:/downloads
    ports:
      - "${QBIT_WEBUI_PORT}:8080"
      - "${QBIT_TORRENT_PORT}:${QBIT_TORRENT_PORT}"
      - "${QBIT_TORRENT_PORT}:${QBIT_TORRENT_PORT}/udp"
    restart: unless-stopped
EOF

# Rechte auf compose-Dateien setzen
chown "$TARGET_USER:$TARGET_USER" \
  "$DOCKER_DIR/jellyfin-compose.yaml" \
  "$DOCKER_DIR/seerr-compose.yaml" \
  "$DOCKER_DIR/sonarr-compose.yaml" \
  "$DOCKER_DIR/radarr-compose.yaml" \
  "$DOCKER_DIR/qbittorrent-compose.yaml"
############################################################
# 3/3 — Docker-Stacks starten & Status ausgeben
############################################################

su - "$TARGET_USER" -c "cd \"$DOCKER_DIR\" && docker compose -f jellyfin-compose.yaml up -d"
su - "$TARGET_USER" -c "cd \"$DOCKER_DIR\" && docker compose -f seerr-compose.yaml up -d"
su - "$TARGET_USER" -c "cd \"$DOCKER_DIR\" && docker compose -f sonarr-compose.yaml up -d"
su - "$TARGET_USER" -c "cd \"$DOCKER_DIR\" && docker compose -f radarr-compose.yaml up -d"
su - "$TARGET_USER" -c "cd \"$DOCKER_DIR\" && docker compose -f qbittorrent-compose.yaml up -d"

su - "$TARGET_USER" -c "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"

echo "----------------------------------------------------"
echo "Setup abgeschlossen."
echo "Dienste laufen (falls keine Fehler gemeldet wurden)."
echo
echo "Jellyfin:      http://${SERVER_IP}:${JELLYFIN_PORT}"
echo "Seerr:         http://${SERVER_IP}:${SEERR_PORT}"
echo "Sonarr:        http://${SERVER_IP}:${SONARR_PORT}"
echo "Radarr:        http://${SERVER_IP}:${RADARR_PORT}"
echo "qBittorrent:   http://${SERVER_IP}:${QBIT_WEBUI_PORT}"
echo
echo "Jellyfin Custom CSS ist in:"
echo "  $JELLYFIN_CONFIG_DIR/branding.xml"
echo "Alle Docker-Daten liegen unter:"
echo "  $DOCKER_DIR"
echo "Jetzt einmal Jellyfin im Browser öffnen und den Setup-Wizard durchklicken."
