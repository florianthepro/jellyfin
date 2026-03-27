#!/usr/bin/env bash
if [ "$EUID" -ne 0 ]; then echo "Bitte als root oder mit sudo ausführen: sudo $0"; exit 1; fi
echo "===== ALTES SSH KOMPLETT ENTFERNEN ====="
systemctl stop ssh 2>/dev/null || true
apt purge -y openssh-server openssh-client openssh-sftp-server 2>/dev/null || true
apt autoremove -y 2>/dev/null || true
rm -rf /etc/ssh 2>/dev/null || true
echo "===== SSH BASIC NEU INSTALLIEREN ====="
apt update
apt install -y openssh-server
echo "Neue SSH-Host-Keys erzeugen (falls nötig)..."
ssh-keygen -A
sshdConfig="/etc/ssh/sshd_config"
echo "SSH-Konfiguration auf Basic (User + Passwort) setzen..."
if [ -f "$sshdConfig" ]; then
sed -i 's/^[#[:space:]]*PasswordAuthentication.*/PasswordAuthentication yes/' "$sshdConfig"
sed -i 's/^[#[:space:]]*PermitRootLogin.*/PermitRootLogin no/' "$sshdConfig"
if ! grep -qi '^PasswordAuthentication' "$sshdConfig"; then echo 'PasswordAuthentication yes' >> "$sshdConfig"; fi
if ! grep -qi '^PermitRootLogin' "$sshdConfig"; then echo 'PermitRootLogin no' >> "$sshdConfig"; fi
fi
echo "SSH-Dienst aktivieren und starten..."
systemctl enable ssh >/dev/null 2>&1 || true
systemctl restart ssh
echo "Firewall (UFW) für SSH öffnen (falls vorhanden)..."
if command -v ufw >/dev/null 2>&1; then
ufw allow ssh >/dev/null 2>&1 || true
yes | ufw enable >/dev/null 2>&1 || true
fi
ipAdresse=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$ipAdresse" ]; then
ipAdresse=$(ip -4 addr show scope global 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)
fi
echo
echo "============== SSH BASIC RESET FERTIG =============="
echo "SSH läuft jetzt frisch mit Benutzer+Passwort-Login."
echo "IP-Adresse des Servers: $ipAdresse"
echo "Port: 22"
echo
echo "Hinweis für Windows, wenn die Meldung"
echo "  WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"
echo "kommt, auf dem Windows-Client ausführen:"
echo "  ssh-keygen -R $ipAdresse"
echo "und dann erneut verbinden mit:"
echo "  ssh <BENUTZER>@$ipAdresse"
echo "===================================================="
