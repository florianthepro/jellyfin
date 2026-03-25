#!/bin/sh
set -e
if [ "$(id -u)" -ne 0 ]; then
echo "Starte Script mit Root-Rechten über sudo..."
exec sudo "$0" "$@"
fi
DEFAULT_USER="$SUDO_USER"
if [ -z "$DEFAULT_USER" ] || [ "$DEFAULT_USER" = "root" ]; then
DEFAULT_USER="$(logname 2>/dev/null || id -un)"
fi
printf "Ziel-Linux-Benutzer für Docker/Jellyfin (Enter für %s): " "$DEFAULT_USER"
read -r TARGET_USER
if [ -z "$TARGET_USER" ]; then
TARGET_USER="$DEFAULT_USER"
fi
if ! id "$TARGET_USER" >/dev/null 2>&1; then
echo "Benutzer '$TARGET_USER' existiert nicht. Abbruch."
exit 1
fi
HOME_DIR="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
if [ -z "$HOME_DIR" ]; then
echo "Konnte Home-Verzeichnis von '$TARGET_USER' nicht bestimmen. Abbruch."
exit 1
fi
JELLYFIN_DIR="$HOME_DIR/jellyfin"
SERIES_DIR="$JELLYFIN_DIR/series"
DOCKER_DIR="$HOME_DIR/docker"
mkdir -p "$JELLYFIN_DIR" "$SERIES_DIR" "$DOCKER_DIR"
chown -R "$TARGET_USER:$TARGET_USER" "$JELLYFIN_DIR" "$DOCKER_DIR"
echo "Verzeichnisse angelegt:"
echo "  $JELLYFIN_DIR"
echo "  $SERIES_DIR"
echo "  $DOCKER_DIR"
echo "Führe allgemeine System-Updates aus..."
apt-get update
apt-get upgrade -y
echo "Installiere Basis-Pakete..."
apt-get install -y ca-certificates curl gnupg lsb-release
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
echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable" > "$DOCKER_LIST"
fi
apt-get update
echo "Installiere Docker Engine und Compose-Plugin..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker.service
systemctl enable --now containerd.service
if ! getent group docker >/dev/null 2>&1; then
groupadd docker
fi
if ! getent group docker | grep -q "\b$TARGET_USER\b"; then
usermod -aG docker "$TARGET_USER"
echo "Benutzer '$TARGET_USER' zur Gruppe 'docker' hinzugefügt."
fi
SERVER_IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
if [ -z "$SERVER_IP" ]; then
SERVER_IP="$(ip -4 addr show scope global 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)"
fi
if [ -z "$SERVER_IP" ]; then
SERVER_IP="127.0.0.1"
fi
echo "Ermittelte Server-IP: $SERVER_IP"
ENV_FILE="$DOCKER_DIR/.env"
cat >"$ENV_FILE" <<EOF
SERVER_IP=$SERVER_IP
JELLYFIN_URL=http://$SERVER_IP:8096
SEERR_URL=http://$SERVER_IP:5055
SONARR_URL=http://$SERVER_IP:8989
RADARR_URL=http://$SERVER_IP:7878
QBITTORRENT_URL=http://$SERVER_IP:8080
JELLYFIN_SERIES_PATH=$SERIES_DIR
EOF
chown "$TARGET_USER:$TARGET_USER" "$ENV_FILE"
echo ".env mit Base-URLs und Pfaden erstellt unter $ENV_FILE"
printf "GitHub-Benutzername für das Repo (z.B. 'example-user'): "
read -r GITHUB_USER
if [ -z "$GITHUB_USER" ]; then
echo "Kein GitHub-Benutzername angegeben. Abbruch."
exit 1
fi
BASE_RAW="https://raw.githubusercontent.com/$GITHUB_USER/jellyfin/refs/heads/main"
FILES="jellyfin-compose.yaml seerr-compose.yaml sonarr-compose.yaml radarr-compose.yaml qbittorrent-compose.yaml"
for F in $FILES; do
URL="$BASE_RAW/$F"
TARGET="$DOCKER_DIR/$F"
echo "Lade $URL ..."
if curl -fsSL "$URL" -o "$TARGET"; then
chown "$TARGET_USER:$TARGET_USER" "$TARGET"
echo "Gespeichert: $TARGET"
else
echo "Fehler beim Laden von $URL"
exit 1
fi
done
echo "Starte Docker-Stacks als Benutzer '$TARGET_USER'..."
for F in $FILES; do
echo "Starte Stack aus $F ..."
su - "$TARGET_USER" -c "cd \"$DOCKER_DIR\" && docker compose -f \"$F\" up -d"
done
echo "Basis-Setup abgeschlossen."
echo "Container-Status (Auszug):"
su - "$TARGET_USER" -c "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
echo "Wichtige URLs:"
echo "  Jellyfin:      http://$SERVER_IP:8096"
echo "  Seerr:         http://$SERVER_IP:5055"
echo "  Sonarr:        http://$SERVER_IP:8989"
echo "  Radarr:        http://$SERVER_IP:7878"
echo "  qBittorrent:   http://$SERVER_IP:8080"
echo "Nächste Schritte (manuell oder per weiterem Script):"
echo "  - Jellyfin-Admin, Bibliothek 'Serien' und Jellyfin-Enhanced konfigurieren"
echo "  - Seerr-Owner, Sonarr/Radarr/qBittorrent einrichten und verknüpfen"
