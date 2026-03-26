#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]; then echo "Bitte als root oder mit sudo ausführen: sudo $0"; exit 1; fi
echo "Aktualisiere Paketquellen..."
apt update
echo "Installiere OpenSSH-Server und UFW (falls noch nicht installiert)..."
apt install -y openssh-server ufw
echo "Aktiviere und starte SSH-Dienst..."
systemctl enable --now ssh
echo "Konfiguriere Firewall für SSH (UFW)..."
if command -v ufw >/dev/null 2>&1; then
ufw allow ssh
yes | ufw enable >/dev/null 2>&1 || true
fi
ipAdresse=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$ipAdresse" ]; then
ipAdresse=$(ip -4 addr show scope global 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)
fi
linuxUser=${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}
echo
echo "================ SSH-Setup abgeschlossen ================"
echo "SSH-Dienst-Status:"
systemctl --no-pager --full status ssh | sed -n '1,5p'
echo
echo "Verbindungsdaten für Windows:"
echo "  Benutzername: $linuxUser"
echo "  IP-Adresse:   $ipAdresse"
echo "--------------------------------------------------------"
echo "1) Verbindung über Windows PowerShell oder Eingabeaufforderung:"
echo "   ssh $linuxUser@$ipAdresse"
echo
echo "2) Verbindung über Windows Terminal:"
echo "   Neues Profil erstellen und folgenden Befehl verwenden:"
echo "   ssh $linuxUser@$ipAdresse"
echo
echo "3) Verbindung mit PuTTY:"
echo "   Host Name (oder IP address): $ipAdresse"
echo "   Port: 22"
echo "   Connection type: SSH"
echo "========================================================"
``
