#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]; then echo "Bitte als root oder mit sudo ausführen: sudo $0"; exit 1; fi
echo "===== Einfaches SSH-Setup (User + Passwort) ====="
read -rp "SSH-Benutzername (wird angelegt, falls nicht vorhanden): " sshUser
if [ -z "$sshUser" ]; then echo "Kein Benutzername angegeben, Abbruch."; exit 1; fi
echo "Paketquellen aktualisieren..."
apt update
echo "OpenSSH-Server und UFW installieren..."
apt install -y openssh-server ufw
echo "SSH-Dienst stoppen und alte Host-Schlüssel entfernen..."
systemctl stop ssh 2>/dev/null || true
rm -f /etc/ssh/ssh_host_* 2>/dev/null || true
echo "Neue SSH-Host-Schlüssel erzeugen..."
ssh-keygen -A
echo "SSH-Konfiguration für Passwort-Login anpassen..."
sshdConfig="/etc/ssh/sshd_config"
if [ -f "$sshdConfig" ]; then
sed -i 's/^[#[:space:]]*PasswordAuthentication.*/PasswordAuthentication yes/' "$sshdConfig"
sed -i 's/^[#[:space:]]*PermitRootLogin.*/PermitRootLogin no/' "$sshdConfig"
if ! grep -qi '^PasswordAuthentication' "$sshdConfig"; then echo 'PasswordAuthentication yes' >> "$sshdConfig"; fi
if ! grep -qi '^PermitRootLogin' "$sshdConfig"; then echo 'PermitRootLogin no' >> "$sshdConfig"; fi
fi
echo "SSH-Dienst aktivieren und starten..."
systemctl enable ssh >/dev/null 2>&1 || true
systemctl restart ssh
echo "Firewall (UFW) für SSH konfigurieren..."
if command -v ufw >/dev/null 2>&1; then
ufw allow ssh >/dev/null 2>&1 || true
yes | ufw enable >/dev/null 2>&1 || true
fi
echo "Benutzer $sshUser prüfen/anlegen..."
if id "$sshUser" >/dev/null 2>&1; then
echo "Benutzer $sshUser existiert, Passwort wird neu gesetzt."
else
adduser --gecos "" "$sshUser"
fi
echo "Passwort für Benutzer $sshUser setzen/ändern:"
passwd "$sshUser"
ipAdresse=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$ipAdresse" ]; then
ipAdresse=$(ip -4 addr show scope global 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)
fi
echo
echo "================ Fertig ================"
echo "SSH läuft mit User+Passwort."
echo "Benutzer:  $sshUser"
echo "IP:        $ipAdresse"
echo "Port:      22"
echo
echo "Hinweis für Windows, falls alte Hostkeys Probleme machen:"
echo "  ssh-keygen -R $ipAdresse"
echo "und dann verbinden mit:"
echo "  ssh $sshUser@$ipAdresse"
echo "========================================"
``
