#!/bin/sh
clear
set -euo pipefail
cd /home/$(whoami)
sudo apt update -y
sudo apt upgrade -y

ask() {
printf "%s" "$1" >/dev/tty
IFS= read -r REPLY </dev/tty
}

clear
cat <<'END'
>goto https://login.tailscale.com/admin/acls/file
>press "Edit anyway..."
>add:
====================
	"nodeAttrs": [
		{
			"target": ["autogroup:member"],
			"attr":   ["funnel"]
		}
	]
===================
END
ask "done? "

clear
username="$(whoami)"
userid="$(id -u)"
groupid="$(id -g)"

clear
ask "Please enter your Password: "
userpass="$REPLY"

while :; do

clear
ask "language ('de' or 'en'):"
language="$REPLY"

#ui_culture_normalized=$(printf '%s' "$ui_culture" | tr 'A-Z' 'a-z')
case "$language" in
de|en)
break
;;
*)
;;
esac
done

case "$ui_culture_normalized" in
  de)
    ui_culture="de"
    display_language="de-de"
    country_code="DE"
    country_name="Germany"
    ;;
  en|*)
    ui_culture="en"
    display_language="en-us"
    country_code="US"
    country_name="United States"
    ;;
esac

clear
cat <<'END'
>goto "https://login.tailscale.com/admin/settings/keys"
>press "Generate auth key..."
END
ask "Enter your Auth Key: "
tsauthkey="$REPLY"

clear
mkdir -p ~/media/music
mkdir -p ~/media/video
mkdir -p ~/media/books
mkdir -p ~/docker
mkdir -p ~/docker/jellyfin
mkdir -p ~/docker/seerr
mkdir -p ~/docker/sonarr
mkdir -p ~/docker/radarr
mkdir -p ~/docker/qbittorrent

sudo curl -L https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/compose.yaml -o ~/docker/compose.yaml
sed -i "s/fill-usr/$username/g" ~/docker/compose.yaml
sed -i "s/fill-key/$tsauthkey/g" ~/docker/compose.yaml

#===== docker =====
sudo apt update -qq -y
sudo apt install -qq -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -qq -y
sudo apt install -qq -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$(whoami)"
clear
curl -sSL https://raw.githubusercontent.com/florianthepro/jellyfin-enhanced-setup/main/setup.sh | bash
