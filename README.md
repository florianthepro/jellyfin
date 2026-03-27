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
