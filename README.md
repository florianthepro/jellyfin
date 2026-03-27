![REPO](https://img.shields.io/badge/REPO-in%20progress-blueviolet?logoColor=white)

---
```mermaid
flowchart LR
%% ===== Bereiche =====
subgraph LOCAL[Lokales Netzwerk aka docker]
direction TB

    %% Jellyfin
    JF[Jellyfin<br/>Port 8096<br/>READ: /media]

    %% Medienbibliothek
    MB[(Medienbibliothek<br/>/home/fill-usr/media)]

    %% Downloader & Manager
    SON[Sonarr<br/>8989<br/>WRITE: /media]
    RAD[Radarr<br/>7878<br/>WRITE: /media]
    QBIT[qBittorrent<br/>8080<br/>WRITE: /media]

    %% Seerr Request Portal
    SEERR[Seerr<br/>5055]

    %% Tailscale Node
    TS[Tailscale Node<br/>host network<br/>Funnel Endpoint]

end

subgraph INTERNET[Öffentlich / Internet]
direction TB
    FUNNEL[Tailscale Funnel<br/>HTTPS 443 → Jellyfin 8096]
    CLIENT[Externes Gerät<br/>Laptop/TV/Phone]
end

%% ===== Verbindungen =====

%% Medienzugriff
JF -->|read| MB
SON -->|write| MB
RAD -->|write| MB
QBIT -->|write| MB

%% API-Flow zwischen Services
SEERR -->|API| SON
SEERR -->|API| RAD
SON -->|API: DL Job| QBIT
RAD -->|API: DL Job| QBIT

%% Tailscale extern
CLIENT -->|HTTPS 443| FUNNEL --> TS --> JF
```
---
Openssh
```
sudo apt update
sudo apt install openssh-server
sudo systemctl enable --now ssh
sudo systemctl restart ssh
ip -4 addr show
#connect: ssh user@ip
```
SSH:
```
curl -sSL https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/ssh.sh | sudo bash
```
Reset:
```
curl -sSL https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/reset.sh | sudo bash
```
Install:
```
curl -sSL https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/install.sh | bash
```
Setup:
```
curl -sSL https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/setup.sh | bash
```
<!--
mkdir -p ~/media/video/series-a/season00/s01E01.mkv & mkdir -p ~/media/video/movie-name/data like mp3 mkv etc
sudo tailscale funnel 8096 on
sudo tailscale funnel on 8096
-->
---
# ziel:
1. allgemeine system-updates prüfen/installieren
2. zielverzeichnisse erstellen:
   - /home/jellyfin/docker
   - /home/jellyfin/series
   - /home/jellyfin/media (falls benötigt)
3. docker installieren + user zu docker gruppe hinzufügen
   compose von meinem repo laden (jellyfin-compose.yaml) nach /home/jellyfin/docker
   jellyfin starten (ohne sudo)
4. jellyfin auto-setup:
   erster user: admin / Password123!
   bibliothek "Serien" → /home/jellyfin/series
5. seerr installieren (seerr-compose.yaml aus repo)
   auto-setup admin / Password123!
6. jellyfin plugin "Enhancer" installieren:
   offizielles repo eintragen + plugin installieren + jellyfin reboot
7. sonarr + radarr installieren (compose-dateien aus repo)
   auto-setup admin / Password123!
8. integration:
   - sonarr API key → seerr
   - radarr API key → seerr
   - qbittorrent API key → sonarr + radarr
9. qbittorrent installieren:
    auto-setup admin / Password123!
10. sicherstellen:
    alle nutzen /home/jellyfin/series korrekt:
      - jellyfin: read
      - sonarr/radarr/qbit: write
11. cleanup:
    default admins entfernen
    default api keys entfernen
12. jellyfin bibliothek prüfen
13. sonarr/radarr/seerr/qbit verbindungen prüfen
14. configuration sauber setzen (basisoptionen)
15. css laden
