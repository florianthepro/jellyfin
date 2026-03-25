#!/bin/sh
set -e
echo "=== STEP 0: Root-Prüfung ==="
if [ "$(id -u)" -ne 0 ]; then
echo "Dieses Script muss als root ausgeführt werden."
exit 1
fi
echo "=== STEP 1: Zielbenutzer und Jellyfin-Verzeichnis bestimmen ==="
DEFAULT_USER="${SUDO_USER:-$(id -un)}"
printf "Linux-Benutzername für Jellyfin/Docker (Enter für %s): " "$DEFAULT_USER"
read TARGET_USER
if [ -z "$TARGET_USER" ]; then
TARGET_USER="$DEFAULT_USER"
fi
if ! id "$TARGET_USER" >/dev/null 2>&1; then
echo "Benutzer '$TARGET_USER' existiert nicht. Abbruch."
exit 1
fi
HOME_DIR=$(getent passwd "$TARGET_USER" | cut -d: -f6)
if [ -z "$HOME_DIR" ]; then
echo "Konnte Home-Verzeichnis von '$TARGET_USER' nicht bestimmen. Abbruch."
exit 1
fi
JELLYFIN_DIR="$HOME_DIR/jellyfin"
DOCKER_DIR="$JELLYFIN_DIR/docker"
mkdir -p "$DOCKER_DIR"
chown -R "$TARGET_USER:$TARGET_USER" "$JELLYFIN_DIR"
echo "Verzeichnis für Jellyfin angelegt: $DOCKER_DIR"
echo "=== STEP 2: System aktualisieren und Basis-Pakete installieren ==="
apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release
echo "=== STEP 3: Docker-Repository nach offizieller Docker-Doku einrichten ==="
if [ ! -d /etc/apt/keyrings ]; then
install -m 0755 -d /etc/apt/keyrings
fi
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
fi
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
DOCKER_LIST=/etc/apt/sources.list.d/docker.list
if [ ! -f "$DOCKER_LIST" ]; then
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable" > "$DOCKER_LIST"
fi
apt-get update
echo "=== STEP 4: Docker Engine und Compose installieren ==="
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker.service
systemctl enable --now containerd.service
if getent group docker >/dev/null 2>&1; then
echo "Gruppe 'docker' existiert bereits."
else
groupadd docker
fi
if getent group docker | grep -q "\b$TARGET_USER\b"; then
echo "Benutzer '$TARGET_USER' ist bereits in der Gruppe 'docker'."
else
usermod -aG docker "$TARGET_USER"
echo "Benutzer '$TARGET_USER' wurde der Gruppe 'docker' hinzugefügt."
fi
echo "=== STEP 5: Tailscale installieren und starten ==="
if command -v tailscale >/dev/null 2>&1; then
echo "Tailscale ist bereits installiert."
else
curl -fsSL https://tailscale.com/install.sh | sh
fi
systemctl enable --now tailscaled.service
echo "Tailscale wird jetzt konfiguriert. Es erscheint eine URL zur Anmeldung."
echo "Öffne die URL im Browser und füge den Server deinem Tailscale-Netz hinzu."
tailscale up || true
echo "=== STEP 6: GitHub-Benutzernamen abfragen ==="
printf "GitHub-Benutzername (ohne https, z.B. 'example-user'): "
read GITHUB_USER
if [ -z "$GITHUB_USER" ]; then
echo "Kein GitHub-Benutzername angegeben. Abbruch."
exit 1
fi
echo "=== STEP 7: compose.yaml aus GitHub-Repo laden ==="
COMPOSE_URL="https://raw.githubusercontent.com/$GITHUB_USER/jellyfin/refs/heads/main/compose.yaml"
COMPOSE_TARGET="$DOCKER_DIR/compose.yaml"
echo "Lade: $COMPOSE_URL"
if curl -fsSL "$COMPOSE_URL" -o "$COMPOSE_TARGET"; then
chown "$TARGET_USER:$TARGET_USER" "$COMPOSE_TARGET"
echo "compose.yaml gespeichert unter: $COMPOSE_TARGET"
else
echo "Fehler: Konnte compose.yaml von $COMPOSE_URL nicht herunterladen."
echo "Bitte prüfe Repo/Branch/Dateinamen und starte das Script erneut."
exit 1
fi
echo "=== STEP 8: Docker Compose-Stack starten ==="
cd "$DOCKER_DIR"
sudo -u "$TARGET_USER" docker compose -f "$COMPOSE_TARGET" up -d
echo "Docker-Stack wurde gestartet."
echo "Fertig. Du kannst dich als '$TARGET_USER' anmelden und mit 'cd \"$DOCKER_DIR\"' und 'docker compose' weiterarbeiten."
