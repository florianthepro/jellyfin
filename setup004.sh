#!/bin/sh
set -e

TARGET_USER="florianthepro"
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
