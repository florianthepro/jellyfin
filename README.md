# WIP
```
sudo rm -rf *
```
```
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
```
```
curl -sSL https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/install.sh | bash
```
```
curl -sSL https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/setup.sh | bash
```
---
```
ziel:
1. Script muss als admin
2. Allgemeine updates checken
3. Zielverzeichnis jellyfin und docker in home erstellen
3.1 series in jellyfin in homes erstellen
4. Docker installiren (sodass man bei befehlen kein sudo braucht) und compose von https://raw.githubusercontent.com/florianthepro/jellyfin/refs/heads/main/jellyfin-compose.yaml laden in ordner docker (der der in docker ist) und starten
5. normalerweiße kann user nun im web setup machen aber bei uns soll das script selber den ersten (admin) user auf "admin" mit passwort "Password123!" festlegen
6. Seerr installiren (seerr-compose.yaml) ist in meinem repo
7. Plugin Jellyfin Enhanct installiren (offizelles repo in jellyfin hinterlegen und installiren und reboot)
8. Seerr setup (selber admin user mit Password123!
9. sonarr und ViedeoRarr installation&setup mit selben admin user und jewals via offizeller docker (sonarr-compose.yaml und die radarr-compose.yaml in meinem repo (offizelle version)
10. Sonarr Vidoarr in Seerr integriren api keys 
11. Sauberes dateien (seerr und Soarr und so sollen /home/jellyfin/series serien speichern)
12. entsprechend qBitttorent installiren selben admin user
13. achte darauf das /home/jellyfin/series sauber von allem benutzt wird und saubere die default admins und die api keys sauber ausgetauscht
14. Bibelothek "Serien" mit pfad zu series in jellyfin anlegen (rest default)
15. configuration von sachen wie das sie sich sauber
16 css
```
fertig

3MU epg xml: ```https://epg.pw/xmltv/epg.xml```

#mkdir -p ~/media/video/series-a/season00/s01E01.mkv & mkdir -p ~/media/video/movie-name/data like mp3 mkv etc
#sudo tailscale funnel 8096 on
#sudo tailscale funnel on 8096
