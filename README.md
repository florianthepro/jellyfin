![REPO](https://img.shields.io/badge/REPO-in%20progress-blueviolet?logoColor=white)

---
Delete old docker:
```
sudo rm -rf *
```
```
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
```
---
Install:
```
curl -sSL https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/install.sh | bash
```
Setup:
```
curl -sSL https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/setup.sh | bash
```
---
```
ziel:
1. script muss als admin laufen
2. allgemeine system-updates prüfen/installieren
3. zielverzeichnisse erstellen:
   - /home/jellyfin/docker
   - /home/jellyfin/series
   - /home/jellyfin/media (falls benötigt)
4. docker installieren + user zu docker gruppe hinzufügen
   compose von meinem repo laden (jellyfin-compose.yaml) nach /home/jellyfin/docker
   jellyfin starten (ohne sudo)
5. jellyfin auto-setup:
   erster user: admin / Password123!
   bibliothek "Serien" → /home/jellyfin/series
6. seerr installieren (seerr-compose.yaml aus repo)
   auto-setup admin / Password123!
7. jellyfin plugin "Enhancer" installieren:
   offizielles repo eintragen + plugin installieren + jellyfin reboot
8. sonarr + radarr installieren (compose-dateien aus repo)
   auto-setup admin / Password123!
9. integration:
   - sonarr API key → seerr
   - radarr API key → seerr
   - qbittorrent API key → sonarr + radarr
10. qbittorrent installieren:
    auto-setup admin / Password123!
11. sicherstellen:
    alle nutzen /home/jellyfin/series korrekt:
      - jellyfin: read
      - sonarr/radarr/qbit: write
12. cleanup:
    default admins entfernen
    default api keys entfernen
13. jellyfin bibliothek prüfen
14. sonarr/radarr/seerr/qbit verbindungen prüfen
15. configuration sauber setzen (basisoptionen)
16. css laden
```
fertig

3MU epg xml: ```https://epg.pw/xmltv/epg.xml```

#mkdir -p ~/media/video/series-a/season00/s01E01.mkv & mkdir -p ~/media/video/movie-name/data like mp3 mkv etc
#sudo tailscale funnel 8096 on
#sudo tailscale funnel on 8096
