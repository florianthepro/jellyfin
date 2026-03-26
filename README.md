![REPO](https://img.shields.io/badge/REPO-in%20progress-blueviolet?logoColor=white)

Openssh
```
sudo apt update
sudo apt install openssh-server
sudo systemctl enable --now ssh
sudo ufw status
sudo ufw allow OpenSSH
sudo ufw enable
sudo systemctl restart ssh
```
Reset:
```
sudo rm -rf *
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
<!--
mkdir -p ~/media/video/series-a/season00/s01E01.mkv & mkdir -p ~/media/video/movie-name/data like mp3 mkv etc
sudo tailscale funnel 8096 on
sudo tailscale funnel on 8096
